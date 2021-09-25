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
    @IBOutlet weak var startButton: UIButton!
    
    var startButtonTintColor: UIColor? = UIColor.black
    var startButtonBackgroundColor: UIColor? = UIColor.white
    
    let welcometext = NSLocalizedString("WelcomeText", comment: "Header text")
    let messageText = NSLocalizedString("WelcomeMessage", comment: "Message text")
    let startButtonTitle = NSLocalizedString("StartButtonTitle", comment: "Start button title")
    
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
        
        startButton.setTitle(startButtonTitle, for: UIControl.State())
        startButton.tintColor = startButtonTintColor
        startButton.backgroundColor = startButtonBackgroundColor
        startButton.layer.cornerRadius = CGFloat(22.0)
    }
    
    private func applyTheme() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        startButtonTintColor = isDarkMode ? .black : .white
        startButtonBackgroundColor = isDarkMode ? .white : .black
    }
    
    // MARK: - IBActions
    @IBAction func startButtonAction(_ sender: Any) {
        coordinator?.startButtonTapped()
    }
}
