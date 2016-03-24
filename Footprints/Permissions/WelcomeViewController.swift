//
//  WelcomeViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/24/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var headingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headingLabel.font = AppTheme.headingFont
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func permissionAction(sender: AnyObject) {
        if let locationPermissionViewController = storyboard?.instantiateViewControllerWithIdentifier("locationPermissionViewController") {
            navigationController?.pushViewController(locationPermissionViewController, animated: true)
        }
    }
    
}
