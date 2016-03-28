//
//  CreateBaseViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/28/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit

class CreateBaseViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        CloudKitHelper.checkAccountStatus({
            if let createFootprintNavigationController = self.storyboard?.instantiateViewControllerWithIdentifier("createFootprintNavigationController") as? UINavigationController {
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(createFootprintNavigationController, animated: true) {
                        self.tabBarController?.selectedIndex = 0
                    }
                }
            }
            }, onNoAccount: {
                dispatch_async(dispatch_get_main_queue()) {
                    AppError.handleAsAlert("Sign in to iCloud", message: "Sign in to your iCloud account to start using Footprints. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", presentingViewController: self) {
                        self.tabBarController?.selectedIndex = 0
                    }
                }
            }, onRestricted: {
                dispatch_async(dispatch_get_main_queue()) {
                    AppError.handleAsAlert("Restricted Access to iCloud", message: "iCloud access is restricted by parental controls. Please ask your guardian to disable iCloud restrictions.", presentingViewController: self) {
                        self.tabBarController?.selectedIndex = 0
                    }
                }
        }) { (error) in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    AppError.handleAsAlert("Ooops!", message: error.localizedDescription, presentingViewController: self) {
                        self.tabBarController?.selectedIndex = 0
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
