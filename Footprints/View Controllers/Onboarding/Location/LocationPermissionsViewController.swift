//
//  LocationPermissionsViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/26/21.
//

import UIKit
import CoreLocation

class LocationPermissionsViewController: UIViewController, IBInstantiable {
    
    var coordinator: LocationPermissionsCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationPermissionsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .notDetermined, .restricted, .denied:
                LocationService.showEnableAuthorizationAlert(in: self, showOpenSettings: false) {
                    // TODO: navigate to next screen
                    // self?.coordinator.nav...
                }
            case .authorizedAlways, .authorizedWhenInUse, .authorized:
                // TODO: navigate next
                print("Navigate to next screen")
            @unknown default:
                // TODO: navigate next
                print("Navigate to next screen")
            }
        }
    }
}

