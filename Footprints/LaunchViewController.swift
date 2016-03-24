//
//  ViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/24/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        CloudKitHelper.checkAccountStatus({
            dispatch_async(dispatch_get_main_queue()) {
                self.launchInitialViewController()
            }
        }, onNoAccount: {
            dispatch_async(dispatch_get_main_queue()) {
                AppError.handleAsAlert("Sign in to iCloud", message: "Sign in to your iCloud account to start using Footprints. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", presentingViewController: self, completion: nil)
            }
        }, onRestricted: {
            dispatch_async(dispatch_get_main_queue()) {
                AppError.handleAsAlert("Restricted Access to iCloud", message: "iCloud access is restricted by parental controls. Please ask your guardian to disable iCloud restrictions.", presentingViewController: self, completion: nil)
            }
        }, onError: { error in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    AppError.handleAsAlert("Error", message: error.localizedDescription, presentingViewController: self, completion: nil)
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func launchInitialViewController() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if !defaults.boolForKey("permissionsSetup") {
            performSegueWithIdentifier("permissionsNavigationControllerSegue", sender: nil)
        } else {
            performSegueWithIdentifier("mainTabBarControllerSegue", sender: nil)
        }
    }

}

