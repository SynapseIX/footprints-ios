//
//  AppError.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/24/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit

class AppError {
    
    class func handleAsAlert(title: String?, message: String?, presentingViewController: UIViewController, completion: ((action: UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: completion)
        
        alert.addAction(dismissAction)
        presentingViewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func handleAsLog(message: String?) {
        if let message = message {
            NSLog("Error: \(message)")
        }
    }
    
}
