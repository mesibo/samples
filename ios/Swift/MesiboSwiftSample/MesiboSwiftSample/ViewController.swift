//
//  ViewController.swift
//  MesiboSwiftSample

//  Copyright © 2020 Mesibo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func OnSendMessage(_ sender: Any) {
        MesiboSample.getInstance().sendMessage("destination address", message: "Hello, mesibo")
    }
    
}

