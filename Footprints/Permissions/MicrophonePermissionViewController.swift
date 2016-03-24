//
//  MicrophonePermissionViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/24/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit
import AVFoundation

class MicrophonePermissionViewController: UIViewController {
    
    @IBOutlet weak var headingLabel: UILabel!
    
    var audioSession : AVAudioSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headingLabel.font = AppTheme.headingFont
        
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
        } catch {
            let error = error as NSError
            AppError.handleAsAlert("Error", message: error.localizedDescription, presentingViewController: self, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func permissionAction(sender: AnyObject) {
        checkForMicrophoneAccess()
    }
    
    // MARK: - Microphone access methods
    
    private func checkForMicrophoneAccess() {
        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeAudio)
        
        switch authorizationStatus {
        case .NotDetermined:
            requestMicrophoneAccess()
        default:
            handleMicrophoneAccess()
        }
    }
    
    private func requestMicrophoneAccess() {
        weak var weakSelf = self
        
        audioSession.requestRecordPermission { granted in
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.handleMicrophoneAccess()
            }
        }
    }
    
    private func handleMicrophoneAccess() {
        do {
            try audioSession.setActive(false)
            audioSession = nil
            
            if let permissionsSetupViewController = storyboard?.instantiateViewControllerWithIdentifier("permissionsSetupViewController") {
                navigationController?.pushViewController(permissionsSetupViewController, animated: true)
            }
        } catch {
            let error = error as NSError
            AppError.handleAsAlert("Error", message: error.localizedDescription, presentingViewController: self, completion: nil)
        }
    }
    
}