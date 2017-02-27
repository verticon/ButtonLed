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

    private var ledCharacteristic: CentralManager.Characteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        toggleLedButton.isEnabled = false
        toggleLedButton.listener = toggleLed

        // Create the subscription
        
        let buttonCharacteristicId = CentralManager.Identifier(uuid: buttonLedUuids[buttonCharacteristicName]!, name: buttonCharacteristicName)
        let buttonSubscription = CentralManager.CharacteristicSubscription(id: buttonCharacteristicId, discoverDescriptors: false)

        let ledCharacteristicId = CentralManager.Identifier(uuid: buttonLedUuids[ledCharacteristicName]!, name: ledCharacteristicName)
        let ledSubscription = CentralManager.CharacteristicSubscription(id: ledCharacteristicId, discoverDescriptors: false)

        let buttonLedServiceId = CentralManager.Identifier(uuid: buttonLedUuids[buttonLedServiceName]!, name: buttonLedServiceName)
        let serviceSubscription = CentralManager.ServiceSubscription(id: buttonLedServiceId, characteristics: [buttonSubscription, ledSubscription])

        let peripheralSubscription = CentralManager.PeripheralSubscription(services: [serviceSubscription])

        // Obtain a manager for the subscription
        manager = CentralManager(subscription: peripheralSubscription, factory: self) { event in

            switch event { // Respond to the manager's events
                
                case .managerReady:
                    do {
                        print("Core Bluetooth is available and ready to use. Starting scanning.")
                        try self.manager.startScanning()
                    }
                    catch {
                        print("Cannot start scanning: \(error).")
                    }
                    
                case .peripheralReady(let peripheral):
                    
                    print("A peripheral matching our subscription has been discovered.\n\(peripheral).\n\nStopping scanning")
                    self.manager.stopScanning()
                    
                    guard self.ledCharacteristic == nil else {
                        print("The ButtonLed peripheral has already been discovered???")
                        return
                    }

                    guard let buttonLedService = peripheral[buttonLedServiceId] else {
                        print("The peripheral does not have a ButtonLed service???")
                        return
                    }
                    
                    guard let ledCharacteristic = buttonLedService[ledCharacteristicId] else {
                        print("The ButtonLed service does not have an Led characterictic???")
                        return
                    }
                    
                    guard let buttonCharacteristic = buttonLedService[buttonCharacteristicId] else {
                        print("The ButtonLed service does not have a Button characterictic???")
                        return
                    }

                    self.ledCharacteristic = ledCharacteristic
                    self.toggleLedButton.isEnabled = true

                    do {
                        print("Enabling button notifications.")
                        try buttonCharacteristic.notify(enabled: true) { result in

                            switch result {

                                case .success:
                                    print("The hardware button was pushed.")
                                    self.toggleLedButton.toggle()

                                case .failure(let error):
                                    print("A button notification error occurred: \(error).")
                            }
                        }
                    } catch {
                        print("Cannot enable button notifications: \(error).")
                    }

                default:
                    print("Central Manager Event - \(event).")
            }
        }
    }

    // This is the toggle button listener. It will be called whenever the button is toggled.
    //
    // The button will be toggled in one of two ways:
    //     1) The user touches it on the UI causing the button's toggle() method to be invoked.
    //     2) The ButtonLed peripheral's hardware button is pressed. This causes our notification
    //        handler to be invoked. The handler in turn invokes the button's toggle() method.
    //
    // The button's toggle method will invoke the listener. Our listener responds by setting
    // the ButtonLed peripheral's LED to the indicated state.
    private func toggleLed(_ on: Bool) {
        print("Toggling the LED to \(on ? "on" : "off")")

        do {
            try ledCharacteristic.write(Data([on ? 1 : 0])) { result in
                switch result {
                case .success:
                    print("The LED was toggled")
                case .failure(let error):
                    print("Cannot toggle the LED: \(error)")
                }
            }
        } catch {
            print("Cannot write to the LED: \(error)")
        }
    }
}
