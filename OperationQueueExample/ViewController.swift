//
//  ViewController.swift
//  OperationQueueExample
//
//  Created by Esko Vähämäki on 25/09/16.
//  Copyright © 2016 Tuxera. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    let demoVCId = "toDemoViewController"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let demoController = segue.destination as? DemoViewController, let demo = sender as? Demo {
            demoController.currentDemo = demo
        }
    }
    
    func toDemoVCWith(demo: Demo) {
        performSegue(withIdentifier: demoVCId, sender: demo)
    }
    
    @IBAction func baseDemo(_ sender: AnyObject) {
        toDemoVCWith(demo: Demo.baseCase)
    }
    
    @IBAction func priorityDemo(_ sender: AnyObject) {
        toDemoVCWith(demo: Demo.priority)
    }
    
    @IBAction func dependencyDemo(_ sender: AnyObject) {
        toDemoVCWith(demo: Demo.dependencies)
    }
    
}

