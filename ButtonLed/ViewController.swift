//
//  ViewController.swift
//  ButtonLed
//
//  Created by Robert Vaessen on 1/9/17.
//  Copyright © 2017 Robert Vaessen. All rights reserved.
//

import UIKit
import VerticonsToolbox
import MoBetterBluetooth

class ViewController: UIViewController, CentralManagerTypesFactory {

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
    // The button will be toggled in one of two ways:
    //     1) The user touches it on the UI causing the button's toggle() method to be invoked.
    //     2) The ButtonLed peripheral's button is pressed. This causes our notification
    //        handler to be invoked. The handler in turn invokes the button's toggle() method.
    // The button's toggle method will invoke the listener. Our listener responds by setting
    // the ButtonLed peripheral's LED to the indicated state.
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
            print("Central Manager Event - the manager is ready")
            do {
                print("Starting scanning.")
                try manager.startScanning()
            } catch {
                print("Starting scanning caused an exception: \(error).")
            }

        case .peripheralReady(let peripheral):
            print("Central Manager Event - a peripheral matching our subscription has been discovered.\n\(peripheral).")
            guard self.ledCharacteristic == nil else {
                print("The ButtonLed peripheral has already been discovered!")
                return
            }
            process(peripheral:peripheral)

        default:
            print("Central Manager Event - \(event).")
        }
    }
    
    private func process(peripheral: CentralManager.Peripheral) {
        guard let buttonLedService = peripheral[buttonLedServiceId] else {
            print("The peripheral does not have a ButtonLed service.")
            return
        }
        
        
        guard let characteristic = buttonLedService[ledCharacteristicId] else {
            print("The ButtonLed service does not have an Led characterictic.")
            return
        }
        self.ledCharacteristic = characteristic
        toggleLedButton.isEnabled = true
        
        
        guard let buttonCharacteristic = buttonLedService[buttonCharacteristicId] else {
            print("The ButtonLed service does not have a Button characterictic.")
            return
        }
        do {
            print("Enabling button notifications.")
            try buttonCharacteristic.notify(enabled: true) { result in
                switch result {
                case .success:
                    print("Button Notification - the button was pushed.")
                    self.toggleLedButton.toggle()
                case .failure(let error):
                    print("Button Notification - an error occurred: \(error).")
                }
            }
        } catch {
            print("Enabling button notifications caused an exception: \(error).")
        }
    }
}
