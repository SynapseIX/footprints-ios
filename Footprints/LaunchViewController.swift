//
//  ViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/24/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    @IBOutlet weak var retryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initialize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Action
    
    @IBAction func retryAction(sender: AnyObject) {
        initialize()
    }
    
    // MARK: - Methods
    
    func showRetryButton() {
        if retryButton.alpha == 0.0 {
            UIView.animateWithDuration(1.5) {
                self.retryButton.alpha = 1.0
            }
        }
    }
    
    func initialize() {
        CloudKitHelper.checkAccountStatus({
            dispatch_async(dispatch_get_main_queue()) {
                self.launchInitialViewController()
            }
            }, onNoAccount: {
                dispatch_async(dispatch_get_main_queue()) {
                    AppError.handleAsAlert("Sign in to iCloud", message: "Sign in to your iCloud account to start using Footprints. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID.", presentingViewController: self) {
                        self.showRetryButton()
                    }
                }
            }, onRestricted: {
                dispatch_async(dispatch_get_main_queue()) {
                    AppError.handleAsAlert("Restricted Access to iCloud", message: "iCloud access is restricted by parental controls. Please ask your guardian to disable iCloud restrictions.", presentingViewController: self) {
                        self.showRetryButton()
                    }
                }
            }, onError: { error in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        AppError.handleAsAlert("Error", message: error.localizedDescription, presentingViewController: self) {
                            self.showRetryButton()
                        }
                    }
                }
        })
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

