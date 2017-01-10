//
//  StandaloneViewController.swift
//  ButtonLed
//
//  Created by Robert Vaessen on 11/23/15.
//  Copyright © 2015 Robert Vaessen. All rights reserved.
//

import UIKit
import CoreBluetooth
import Toolbox

class StandaloneViewController: UIViewController {

    var centralManager: CBCentralManager!
    var buttonLedPeripheral: CBPeripheral?
    var ledCharacteristic: CBCharacteristic?

    @IBOutlet weak var toggleLedButton: ToggleButton!

    let uuidMappings = [
        CBUUID(string: "2901") : "CharacteristicUserDescription",
        CBUUID(string: "2902") : "ClientCharacteristicConfiguration",
        
        CBUUID(string: "DCBA3154-1212-EFDE-1523-785FEF13D123") : "ButtonLed",
        CBUUID(string: "DCBA1523-1212-EFDE-1523-785FEF13D123") : "LED",
        CBUUID(string: "DCBA1524-1212-EFDE-1523-785FEF13D123") : "Button"]

    override func viewDidLoad() {
        super.viewDidLoad()

        toggleLedButton.listener = toggleLed

        // When creating a CBCentralManager, if bluetooth is turned off then iOS will prompt the user to turn it on
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }

    private func toggleLed(_ on: Bool) {
        if let peripheral = buttonLedPeripheral, let led = ledCharacteristic {
            print("\nTurning the LED \(on ? "on" : "off")")
            
            var stateArray = [UInt8]()
            stateArray.append(on ? 1 : 0)
            let stateData = Data(bytes: UnsafePointer<UInt8>(UnsafePointer<UInt8>(stateArray)), count: 1)
            
            peripheral.writeValue(stateData, for: led, type: .withResponse)
            peripheral.readValue(for: led)
        } else {
            print("The ButtonLed peripheral and/or LED characteristic are nil")
        }
    }
}

extension StandaloneViewController : CBCentralManagerDelegate {
    // This method is invoked when the app is started. It is also invoked whenever the Settings app is used to turn Bluetooth On/Off.
    // If the app is in the foreground and bluetooth is turned On/Off then the invocation occurs immediately. If the app is in the
    // background then the timing of the invocation is determined by the Background Mode setting "Uses Bluetooth LE accessories". If
    // the setting is on then the invocation occurs immediately; else the invocation is deferred until the app is restored to the foreground.
    func centralManagerDidUpdateState(_ manager: CBCentralManager) {
        print("Updated CBCentralManager state to \(getNameForCBManagerState(manager.state)).")
        switch manager.state {
        case .poweredOn:
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey : true]
            manager.scanForPeripherals(withServices: nil, options:options);
            break
            
        default:
            break
        }
    }
    
    func centralManager(_ manager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData data: [String : Any], rssi signalStrength: NSNumber) {
        if let name = peripheral.name , name == "RobertsApplication" {
            buttonLedPeripheral = peripheral  // If a reference is not saved then the memory will be released.
            print("\nDiscovered \(getNameFor(peripheral, includeAncestors: true)) \(peripheral)\n\(data)\nRSSI = \(signalStrength)")
            centralManager.connect(peripheral, options: nil)
            manager.stopScan()
        }
    }
    
    func centralManager(_ manager: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("\nConnected to \(getNameFor(peripheral, includeAncestors: true))")
        peripheral.delegate = self;
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ manager: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("\nFailed to connect to \(getNameFor(peripheral, includeAncestors: true)) - \(error?.localizedDescription)")
    }
    
}

extension StandaloneViewController : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let name = getNameFor(peripheral, includeAncestors: true)
        
        if let error = error {
            print("Error discovering \(name)'s services: \(error.localizedDescription)")
        }
        else {
            var message: String
            
            if let services = peripheral.services {
                message = "\n\(peripheral.name!) has \(services.count) service(s):"
                for service in services {
                    message += "\n\t\(getNameFor(service, includeAncestors: false)) \(service)"
                    peripheral.discoverCharacteristics(nil, for:service)
                }
            }
            else {
                message = "\nThe \(name) peripheral does not have any services"
            }
            
            print(message);
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let serviceName = getNameFor(service, includeAncestors: true)
        
        if let error = error {
            print("Error discovering \(serviceName)'s characteristics: \(error.localizedDescription)")
        }
        else {
            var message: String
            
            if let characteristics = service.characteristics {
                message = "\nThe \(serviceName) service has \(characteristics.count) characteristic(s):"
                for characteristic in characteristics {
                    let characteristicName = getNameFor(characteristic, includeAncestors: false)
                    
                    if (characteristicName == "LED") {
                        ledCharacteristic = characteristic
                    }
                    else if (characteristicName == "Button") {
                        peripheral.setNotifyValue(true, for: characteristic)
                    }
                    else {
                        //if characteristic.properties.rawValue & CBCharacteristicProperties.Read.rawValue != 0 {
                        peripheral.readValue(for: characteristic)
                        //}
                    }
                    
                    peripheral.discoverDescriptors(for: characteristic)
                    
                    message += "\n\t\(characteristicName) \(characteristic)"
                }
            }
            else {
                message = "\nThe \(serviceName) service does not have any characteristics)"
            }
            
            print(message);
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        let name = getNameFor(characteristic, includeAncestors: true)
        
        if let error = error {
            print("Error discovering \(name)'s descriptors: \(error.localizedDescription)")
        }
        else {
            var message: String
            
            if let descriptors = characteristic.descriptors {
                message = "\nThe \(name) characteristic has \(descriptors.count) descriptor(s):"
                for descriptor in descriptors {
                    message += "\n\t\(getNameFor(descriptor, includeAncestors: false)) \(descriptor)"
                    peripheral.readValue(for: descriptor)
                }
            }
            else {
                message = "\nThe \(name) characteristic does not have any descriptors)"
            }
            
            print(message);
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let name = getNameFor(characteristic, includeAncestors: true)
        
        if let error = error {
            print("Error reading the \(name) characteristic's value: \(error.localizedDescription)")
        }
        else {
            if let value = characteristic.value {
                print("\nThe \(name) characteristic's value is \"\(value)\".")
                if name.hasSuffix("Button") {
                    toggleLedButton.toggle()
                }
            }
            else {
                print("\nThe \(name) characteristic's value is nil.")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        let name = getNameFor(characteristic, includeAncestors: true)
        
        if let error = error {
            print("Error writing the \(name) characteristic's value: \(error.localizedDescription)")
        }
        else {
            print("\nThe \(name) characteristic's value was written.")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        let name = getNameFor(descriptor, includeAncestors: true)
        
        if let error = error {
            print("Error reading the \(name) descriptor's value: \(error.localizedDescription)")
        }
        else {
            if let value = descriptor.value {
                print("\nThe \(name) descriptor's value is \(value)")
            }
            else {
                print("\nThe \(name) descriptor's value is nil")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        let name = getNameFor(characteristic, includeAncestors: true)
        
        if let error = error {
            print("Error updating the \(name) characteristic's notification state: \(error.localizedDescription)")
        }
        else {
            print("\nThe \(name) characteristic's notification state was successfully updated.")
        }
    }
}

extension StandaloneViewController {

    func getNameFor(_ bleObject: AnyObject, includeAncestors full: Bool) -> String {
        if let peripheral = bleObject as? CBPeripheral {
            if let name = peripheral.name {
                return name
            }
            return "<unnamed peripheral>";
        }
        else if let service = bleObject as? CBService {
            let shortName = lookupNameFor(service.uuid)
            return full ? "\(getNameFor(service.peripheral, includeAncestors: full))->\(shortName)" : shortName
        }
        else if let characteristic = bleObject as? CBCharacteristic {
            let shortName = lookupNameFor(characteristic.uuid)
            return full ? "\(getNameFor(characteristic.service.peripheral, includeAncestors: full))->\(lookupNameFor(characteristic.service.uuid))->\(shortName)" : shortName
        }
        else if let descriptor = bleObject as? CBDescriptor {
            let shortName = lookupNameFor(descriptor.uuid)
            return full ? "\(getNameFor(descriptor.characteristic.service.peripheral, includeAncestors: full))->\(lookupNameFor(descriptor.characteristic.service.uuid))->\(lookupNameFor(descriptor.characteristic.uuid))->\(shortName)" : shortName
        }
        else {
            return "<Unrecognized object of type \(type(of: bleObject))>";
        }
    }

    func lookupNameFor(_ uuid: CBUUID) -> String {
        if let name = uuidMappings[uuid] {
            return name
        }
        return uuid.uuidString
    }
    
    func getNameForCBManagerState(_ state: CBManagerState) -> String {
        switch state {
        case .poweredOn:
            return "PoweredOn"
        case .poweredOff:
            return "PoweredOff"
        case .resetting:
            return "Resetting"
        case .unauthorized:
            return "Unauthorized"
        case .unknown:
            return "Unknown"
        case .unsupported:
            return "Unsupported"
        }
    }
    
}
