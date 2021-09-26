//
//  LocationService.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/26/21.
//

import CoreLocation
import UIKit

class LocationService {
    private lazy var locationManager =  {
        CLLocationManager()
    }()
    
    var delegate: CLLocationManagerDelegate? {
        get {
            locationManager.delegate
        }
        set {
            locationManager.delegate = newValue
        }
    }
    
    func authorizationStatus() -> CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    static func showEnableAuthorizationAlert(in viewController: UIViewController,
                                             showOpenSettings: Bool,
                                             cancelHandler: (() -> Void)? = nil) {
        
        let title = NSLocalizedString(LocalizableKey.enableLocationAuthorizationAlertTitle, comment: "Alert title")
        let message = NSLocalizedString(LocalizableKey.enableLocationAuthorizationAlertMessage, comment: "Alert title")
        let dismiss = NSLocalizedString(LocalizableKey.dismiss, comment: "Cancel")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: dismiss, style: .cancel) { action in
            cancelHandler?()
        }
        alert.addAction(dismissAction)
        
        if showOpenSettings {
            let openSettings = NSLocalizedString(LocalizableKey.openSettings, comment: "Open Settings")
            let settingsAction = UIAlertAction(title: openSettings, style: .default) { action in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, completionHandler: { success in
                        print("Settings opened: \(success)")
                    })
                }
            }
            alert.addAction(settingsAction)
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
