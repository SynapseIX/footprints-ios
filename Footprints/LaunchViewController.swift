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
            // TODO: check if permissions have been granted and load the correct controllers
            print("Available")
        }, onNoAccount: { [unowned self] in
            dispatch_async(dispatch_get_main_queue()) {
                AppError.handleAsAlert("Sign in to iCloud", message: "Sign in to your iCloud account to start using Footprints. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", presentingViewController: self, completion: nil)
            }
        }, onRestricted: { [unowned self] in
            dispatch_async(dispatch_get_main_queue()) {
                AppError.handleAsAlert("Restricted Access to iCloud", message: "iCloud access is restricted by parental controls. Please ask your guardian to disable iCloud restrictions.", presentingViewController: self, completion: nil)
            }
        }, onError: { [unowned self] error in
            if let error = error {
               AppError.handleAsAlert("Error", message: error.localizedDescription, presentingViewController: self, completion: nil)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}

