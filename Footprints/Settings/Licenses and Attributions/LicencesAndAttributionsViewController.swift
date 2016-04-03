//
//  LicencesAndAttributionsViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 4/2/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit
import GoogleMaps

class LicencesAndAttributionsViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupUI() {
        textView.text = GMSServices.openSourceLicenseInfo()
        textView.font = AppTheme.defaultFont?.fontWithSize(12.0)
        textView.scrollRangeToVisible(NSRange(location: 0, length: 1))
    }

}
