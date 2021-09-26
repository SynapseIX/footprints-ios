//
//  LocationPermissionsViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/26/21.
//

import UIKit
import CoreLocation

class LocationPermissionsViewController: UIViewController, IBInstantiable {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var ctaButton: UIButton!
    
    var ctaButtonTintColor: UIColor? = UIColor.black
    var ctaButtonBackgroundColor: UIColor? = UIColor.white
    
    var coordinator: LocationPermissionsCoordinator?
    
    let greatPlacesMemories = NSLocalizedString(LocalizableKey.greatPlacesMemories, comment: "Title")
    let greatPlacesMessage = NSLocalizedString(LocalizableKey.greatPlacesMessage, comment: "Message")
    let allowLocationAccess = NSLocalizedString(LocalizableKey.allowLocationAccess, comment: "CTA title")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setupUI()
        }
    }
    
    // TODO: add accessibility
    private func setupUI() {
        applyTheme()
        
        welcomeLabel.text = greatPlacesMemories
        messageLabel.text = greatPlacesMessage
        
        ctaButton.setTitle(allowLocationAccess, for: UIControl.State())
        ctaButton.tintColor = ctaButtonTintColor
        ctaButton.backgroundColor = ctaButtonBackgroundColor
        ctaButton.layer.cornerRadius = CGFloat(22.0)
    }
    
    private func applyTheme() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        ctaButtonTintColor = isDarkMode ? .black : .white
        ctaButtonBackgroundColor = isDarkMode ? .white : .black
    }
    
    // MARK: - IBActions
    @IBAction func ctaButtonAction(_ sender: Any) {
        coordinator?.requestAuthorizationTapped()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationPermissionsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .notDetermined:
                break
            case .restricted, .denied:
                LocationService.showEnableAuthorizationAlert(in: self, showOpenSettings: false) {
                    // TODO: navigate to next screen
                    // self?.coordinator.nav...
                    print("Navigate to next screen")
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

