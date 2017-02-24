//
//  UUIDs.swift
//  ButtonLed
//
//  Created by Robert Vaessen on 1/10/17.
//  Copyright © 2017 Robert Vaessen. All rights reserved.
//

import Foundation
import VerticonsToolbox
import CoreBluetooth

let buttonLedServiceName = "ButtonLed"
let buttonCharacteristicName = "Button"
let ledCharacteristicName = "LED"

let buttonLedUuids : BidirectionalDictionary<CBUUID, String> = [
    
    CBUUID(string: "DCBA3154-1212-EFDE-1523-785FEF13D123") : buttonLedServiceName,
    CBUUID(string: "DCBA1523-1212-EFDE-1523-785FEF13D123") : ledCharacteristicName,
    CBUUID(string: "DCBA1524-1212-EFDE-1523-785FEF13D123") : buttonCharacteristicName
]

