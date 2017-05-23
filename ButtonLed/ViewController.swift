//
//  ViewController.swift
//  ButtonLed
//
//  Created by Robert Vaessen on 1/9/17.
//  Copyright © 2017 Robert Vaessen. All rights reserved.
//

import UIKit
import CoreBluetooth
import VerticonsToolbox
import MoBetterBluetooth

class ViewController: UIViewController {

    private let ledCharacteristicId = Identifier(uuid: CBUUID(string: "DCBA1523-1212-EFDE-1523-785FEF13D123"), name: "LED")
    private let buttonCharacteristicId = Identifier(uuid: CBUUID(string: "DCBA1524-1212-EFDE-1523-785FEF13D123"), name: "Button")
    private let buttonLedServiceId = Identifier(uuid: CBUUID(string: "DCBA3154-1212-EFDE-1523-785FEF13D123"), name: "ButtonLed")
    
    private var manager: CentralManager!
    private var peripheral: CentralManager.Peripheral!
    private var ledCharacteristic: CentralManager.Characteristic!

    @IBOutlet weak var toggleLedButton: ToggleButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        toggleLedButton.isEnabled = false // We need to obtain the LED characteristic before we enable the toggle button
        toggleLedButton.listener = toggleLed // Our listener will toggle the LED

        // Create the subscription
        let buttonSubscription = CentralManager.CharacteristicSubscription(id: buttonCharacteristicId)
        let ledSubscription = CentralManager.CharacteristicSubscription(id: ledCharacteristicId)
        let serviceSubscription = CentralManager.ServiceSubscription(id: buttonLedServiceId, characteristics: [buttonSubscription, ledSubscription])
        let peripheralSubscription = CentralManager.PeripheralSubscription(name: "ButtonLed", services: [serviceSubscription], autoConnect: true, autoDiscover: true)

        // Obtain a manager for the subscription
        manager = CentralManager(subscription: peripheralSubscription)

        // Handle the manager's events
        let _ = manager.addListener(self, handlerClassMethod: ViewController.managerEventHandler)
    }
    
    private func managerEventHandler(_ event: CentralManagerEvent) {

        print("Central Manager Event - \(event).")

        switch event { // Respond to the manager's events
            
            case .ready:
                if case .failure(let error) = manager.startScanning()  { print("Cannot start scanning: \(error)") }
            
            case let .peripheralDiscovered(peripheral, _):
                if !manager.stopScanning() { print("Cannot stop scanning") }

                self.peripheral = peripheral
                let _ = peripheral.addListener(self, handlerClassMethod: ViewController.peripheralEventHandler)

            default:
                break
        }
    }

    private func peripheralEventHandler(_ event: PeripheralEvent) {
        
        if case .rssiUpdated = event {} else { print("Peripheral Event - \(event).") } // Don't print rssi updates; they happen too often

        switch event {
            
        case .characteristicsDiscovered(let service):
            
            guard let ledCharacteristic = service[ledCharacteristicId] else {
                print("The \(service.name) service does not have a \(ledCharacteristicId.name!) characterictic???")
                return
            }
            guard let buttonCharacteristic = service[buttonCharacteristicId] else {
                print("The \(service.name) service does not have a \(buttonCharacteristicId.name!) characterictic???")
                return
            }

            // Pressing the toggle button will toggle the hardware LED on/off (see ToggleLed)
            self.ledCharacteristic = ledCharacteristic
            toggleLedButton.isEnabled = true
            

            // Pressing the hardware button will also toggle the hardware LED on/off (see ToggleLed)
            let buttonNotificationHandler = { (result: CentralManager.Characteristic.ReadResult) -> Void in
                switch result {
                case .success:
                    let data = self.peripheral[self.buttonLedServiceId]![self.buttonCharacteristicId]!.cbCharacteristic!.value!
                    print("The hardware button was pushed, value = \(data.toHexString(seperator: " "))")
                    self.toggleLedButton.toggle() // Mirror the effect of pressing the UI's toggle button
                    
                case .failure(let error):
                    print("A button notification error occurred: \(error).")
                }
            }
            if case .failure(let error) = buttonCharacteristic.notify(enabled: true, handler: buttonNotificationHandler) {
                print("Cannot enable button notifications: \(error)")
            }

        default:
            break
            
        }
    }

    // This is the toggle button listener. It will be called whenever the button is toggled.
    //
    // There are two actions which will result in the button being toggled:
    //     1) The user touches it on the UI causing the button's toggle() method to be invoked.
    //     2) The ButtonLed peripheral's hardware button is pressed. This causes our notification
    //        handler to be invoked. The handler in turn invokes the button's toggle() method.
    //
    // The button's toggle method will invoke our listener. The listener responds by setting
    // the ButtonLed peripheral's LED to the indicated state.
    private func toggleLed(_ on: Bool) {
        print("Toggling the LED to \(on ? "on" : "off")")

        let writeCompletionHandler = { (status: PeripheralStatus) -> Void in
            switch status {
            case .success:
                print("The LED was toggled")
            case .failure(let error):
                print("Cannot toggle the LED: \(error)")
            }
        }
        if case .failure(let error) = ledCharacteristic.write(Data([on ? 1 : 0]), completionHandler: writeCompletionHandler) {
            print("Cannot write to the LED: \(error)")
        }
    }
}
