//
//  DemoViewController.swift
//  OperationQueueExample
//
//  Created by Esko Vähämäki on 28/09/16.
//  Copyright © 2016 Tuxera. All rights reserved.
//

import UIKit

enum Demo {
    case baseCase, priority, dependencies
    
    func getName() -> String {
        switch self {
        case .baseCase:
            return "Base case"
        case .priority:
            return "Priority"
        case .dependencies:
            return "Dependencies"
        }
    }
}

class DemoViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var imageView1: UIImageView!
    @IBOutlet var imageView2: UIImageView!
    @IBOutlet var imageView3: UIImageView!
    @IBOutlet var imageView4: UIImageView!
    
    var currentDemo: Demo?
    let operationQueue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = currentDemo?.getName()
    }
    
    func imageViews() -> [UIImageView] {
        return [imageView1, imageView2, imageView3, imageView4]
    }
    
    @IBAction func startDemo(_ sender: AnyObject) {
        if let demo = currentDemo {
            switch demo {
            case .baseCase:
                baseDemo()
            case .priority:
                priorityDemo()
            case .dependencies:
                dependencyDemo()
            }
        }
    }
}
