//
//  LocationPermissionViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/24/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit
import CoreLocation

class LocationPermissionViewController: UIViewController {
    
    @IBOutlet weak var headingLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headingLabel.font = AppTheme.headingFont
        locationManager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func permissionAction(sender: AnyObject) {
        checkForLocationAccess()
    }
    
    // MARK: - Location access methods
    
    private func checkForLocationAccess() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus {
        case .NotDetermined:
            requestLocationAccess()
        default:
            handleLocationAccess()
        }
    }
    
    private func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func handleLocationAccess() {
        if let cameraPermissionsViewController = storyboard?.instantiateViewControllerWithIdentifier("cameraPermissionViewController") {
            navigationController?.pushViewController(cameraPermissionsViewController, animated: true)
        }
    }
    
}

// MARK: - Location manager delegate

extension LocationPermissionViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .Denied {
            weak var weakSelf = self
            
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.handleLocationAccess()
            }
        }
    }
    
}
