//
//  WelcomeViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 9/24/21.
//

import UIKit

class WelcomeViewController: UIViewController, IBInstantiable {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var ctaButton: UIButton!
    
    var ctaButtonTintColor: UIColor? = UIColor.black
    var ctaButtonBackgroundColor: UIColor? = UIColor.white
    
    let welcometext = NSLocalizedString(LocalizableKey.welcomeToFootprints, comment: "Title")
    let messageText = NSLocalizedString(LocalizableKey.welcomeMessage, comment: "Message")
    let startButtonTitle = NSLocalizedString(LocalizableKey.letsGetStarted, comment: "CTA title")
    
    var coordinator: WelcomeCoordinator?
    
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
        
        welcomeLabel.text = welcometext
        messageLabel.text = messageText
        
        ctaButton.setTitle(startButtonTitle, for: UIControl.State())
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
        coordinator?.letsGetStartedTapped()
    }
}

