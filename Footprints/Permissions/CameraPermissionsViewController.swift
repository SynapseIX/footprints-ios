//
//  CameraPermissionsViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/24/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPermissionViewController: UIViewController {
    
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
        checkForCameraAccess()
    }
    
    // MARK: - Camera access methods
    
    private func checkForCameraAccess() {
        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        switch authorizationStatus {
        case .NotDetermined:
            requestCameraAccess()
        default:
            handleCameraAccess()
        }
    }
    
    private func requestCameraAccess() {
        weak var weakSelf = self
        
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.handleCameraAccess()
            }
        }
    }
    
    private func handleCameraAccess() {
        if let microphonePermissionsViewController = storyboard?.instantiateViewControllerWithIdentifier("microphonePermissionViewController") {
            navigationController?.pushViewController(microphonePermissionsViewController, animated: true)
        }
    }
    
}
