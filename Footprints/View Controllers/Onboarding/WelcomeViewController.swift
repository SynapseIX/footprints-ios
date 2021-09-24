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
    
    var coordinator: OnboardingCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // TODO: localize and add accessibility
    private func setupUI() {
        startButton.tintColor = .black
    }
}
