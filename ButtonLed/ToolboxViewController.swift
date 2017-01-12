//
//  ToolboxViewController.swift
//  ButtonLed
//
//  Created by Robert Vaessen on 1/9/17.
//  Copyright © 2017 Robert Vaessen. All rights reserved.
//

import Toolbox
import UIKit

class ToolboxViewController: UIViewController, CentralManagerTypesFactory {

    @IBOutlet weak var toggleLedButton: ToggleButton!

    private var manager: CentralManager!

    private let buttonLedServiceId = CentralManager.Identifier(uuid: buttonLedUuids[buttonLedServiceName]!, name: buttonLedServiceName)
    private let buttonCharacteristicId = CentralManager.Identifier(uuid: buttonLedUuids[buttonCharacteristicName]!, name: buttonCharacteristicName)
    private let ledCharacteristicId = CentralManager.Identifier(uuid: buttonLedUuids[ledCharacteristicName]!, name: ledCharacteristicName)

    private var ledCharacteristic: CentralManager.Characteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        toggleLedButton.isEnabled = false
        toggleLedButton.listener = toggleLed

        let ledSubscription = CentralManager.CharacteristicSubscription(id: ledCharacteristicId, discoverDescriptors: false)
        let buttonSubscription = CentralManager.CharacteristicSubscription(id: buttonCharacteristicId, discoverDescriptors: false)
        let serviceSubscription = CentralManager.ServiceSubscription(id: buttonLedServiceId, characteristics: [buttonSubscription, ledSubscription])
        let peripheralSubscription = CentralManager.PeripheralSubscription(services: [serviceSubscription])

        manager = CentralManager(subscription: peripheralSubscription, factory: self, eventHandler: eventhandler)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // This is the toggle button listener. It will be called whenever the button is toggled.
    // The button can be toggled in one of two ways:
    // 1) The user touches it on the UI causing the button's toggle() method to be invoked.
    // 2) The ButtonLed peripheral's button is pressed. This causes our notification
    //    handler to be invoked. The handler in turn invokes the button's toggle() method.
    private func toggleLed(_ on: Bool) {
        print("Toggling the LED to \(on ? "on" : "off")")

        do {
            try ledCharacteristic.write(Data([on ? 1 : 0])) { result in
                switch result {
                case .success:
                    print("ButtonLed Peripheral - the LED was toggled")
                case .failure(let error):
                    print("ButtonLed Peripheral - the LED could not be toggled: \(error)")
                }
            }
        } catch {
            print("Central Manager - writing the LED caused an exception:  \(error)")
        }
    }

    private func eventhandler(_ event: CentralManager.Event) {
        switch event {

        case .managerReady:
            print("Central Manager - the manager is ready; starting scanning.")
            do {
                try manager.startScanning()
            } catch {
                print("Central Manager - starting scanning caused an exception: \(error).")
            }

        case .peripheralReady(let peripheral):
            guard ledCharacteristic == nil else {
                print("Central Manager -  the ButtonLed peripheral was rediscovered???\n\(peripheral).")
                break
            }

            print("Central Manager - the ButtonLed peripheral's discovery has completed. Enabling button notifications")

            let buttonLedService = peripheral[buttonLedServiceId]!

            ledCharacteristic = buttonLedService[ledCharacteristicId]
            toggleLedButton.isEnabled = true

            do {
                try buttonLedService[buttonCharacteristicId]?.notify(enabled: true) { result in
                    switch result {
                    case .success:
                        print("ButtonLed Peripheral - the button was pushed.")
                        self.toggleLedButton.toggle()
                    case .failure(let error):
                        print("ButtonLed Peripheral - a button notification error occurred: \(error).")
                    }
                }
            } catch {
                print("Central Manager - enabling button notifications caused an exception: \(error).")
            }


        default:
            print("Central Manager - the manager sent an event: \(event).")
        }
    }
}
