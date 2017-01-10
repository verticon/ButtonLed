//
//  ToolboxViewController.swift
//  ButtonLed
//
//  Created by Robert Vaessen on 1/9/17.
//  Copyright © 2017 Robert Vaessen. All rights reserved.
//

import Toolbox
import UIKit

class ToolboxViewController: UIViewController {

    @IBOutlet weak var toggleLedButton: ToggleButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleLedButton.listener = toggleLed
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func toggleLed(_ on: Bool) {
        print("Turning the LED \(on ? "on" : "off")")
    }

    @IBAction func toggleLed(_ sender: UIButton) {
    }
}
