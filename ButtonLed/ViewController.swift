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
    private var buttonCharacteristic: CentralManager.Characteristic!

    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var toggleLedButton: ToggleButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        readButton.isHidden = true

        toggleLedButton.listener = toggleLed // Our listener will toggle the LED

        // Create the subscription
        let buttonSubscription = CentralManager.CharacteristicSubscription(id: buttonCharacteristicId)
        let ledSubscription = CentralManager.CharacteristicSubscription(id: ledCharacteristicId)
        let serviceSubscription = CentralManager.ServiceSubscription(id: buttonLedServiceId, characteristics: [buttonSubscription, ledSubscription])
        let peripheralSubscription = CentralManager.PeripheralSubscription(name: "ButtonLed", services: [serviceSubscription], autoConnect: true, autoDiscover: true)

        // Obtain a manager for the subscription
        manager = CentralManager(subscription: peripheralSubscription)

        // Handle the manager's events
        _ = manager.addListener(self, handlerClassMethod: ViewController.managerEventHandler)
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
            self.ledCharacteristic = ledCharacteristic

            guard let buttonCharacteristic = service[buttonCharacteristicId] else {
                print("The \(service.name) service does not have a \(buttonCharacteristicId.name!) characterictic???")
                return
            }
            self.buttonCharacteristic = buttonCharacteristic

            if case .failure(let error) = ledCharacteristic.read({ (result: CentralManager.Characteristic.ReadResult) -> Void in
                    switch result {
                    case .success(let data):
                        // Pressing the toggle button will toggle the hardware LED on/off (see ToggleLed)
                        self.toggleLedButton.isEnabled = true
                        self.toggleLedButton.isSelected = (data[0] & 1) != 0 // Selected if LED is on
                        
                    case .failure(let error):
                        print("An led read error occurred: \(error).")
                    }
                })
            {
                print("Cannot read the led: \(error)")
            }

            readButton.isEnabled = true

            // Via notifications the hardware button is made to mirror the toggle button
            if case .failure(let error) = buttonCharacteristic.notify(enabled: true, handler: { (result: CentralManager.Characteristic.ReadResult) -> Void in
                switch result {
                case .success:
                    print("The hardware button was pressed.")
                    self.toggleLedButton.toggle()
                case .failure(let error):
                    print("A button notification error occurred: \(error).")
                }
            }) {
                print("Cannot enable button notifications: \(error).")
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
    // The button's toggle method will invoke our listener. The listener responds by toggling
    // the ButtonLed peripheral's LED.
    private func toggleLed(_ newState: Bool) {
        print("Toggling the LED to \(newState ? "on" : "off")")

        let writeCompletionHandler = { (status: PeripheralStatus) -> Void in
            switch status {
            case .success:
                print("The LED was successfully toggled")
            case .failure(let error):
                print("Cannot toggle the LED: \(error)")
            }
        }
        if case .failure(let error) = ledCharacteristic.write(Data([newState ? 1 : 0]), completionHandler: writeCompletionHandler) {
            print("Cannot write to the LED: \(error)")
        }
    }

    @IBAction func readCharacteristics(_ sender: Any) {
        let buttonReadHandler = { (result: CentralManager.Characteristic.ReadResult) -> Void in
            switch result {
            case .success(let data):
                print("The button's value is \(data.toHexString(seperator: " "))")
                
            case .failure(let error):
                print("A button read error occurred: \(error).")
            }
        }
        if case .failure(let error) = buttonCharacteristic.read(buttonReadHandler) {
            print("Cannot read the button: \(error)")
        }

        let ledReadHandler = { (result: CentralManager.Characteristic.ReadResult) -> Void in
            switch result {
            case .success(let data):
                print("The led's value is \(data.toHexString(seperator: " "))")
                
            case .failure(let error):
                print("An led read error occurred: \(error).")
            }
        }
        if case .failure(let error) = ledCharacteristic.read(ledReadHandler) {
            print("Cannot read the led: \(error)")
        }
    }
}
