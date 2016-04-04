//
//  SelectDateViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 11/13/15.
//  Copyright © 2015 Jorge Tapia. All rights reserved.
//

import UIKit

class SelectDateViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var calendarViewTopSpaceConstraint: NSLayoutConstraint!
    
    weak var delegate: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if DeviceModel.iPhone5 {
            calendarViewTopSpaceConstraint.constant = 50.0
        } else if DeviceModel.iPhone6 {
            calendarViewTopSpaceConstraint.constant = 80.0
        } else if DeviceModel.iPhone6Plus {
            calendarViewTopSpaceConstraint.constant = 110.0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func saveAction(sender: AnyObject) {
        if delegate is CreateFootprintTableViewController {
            (delegate as? CreateFootprintTableViewController)?.footprint.date = datePicker.date
        } else if delegate is DetailTableViewController {
            (delegate as? DetailTableViewController)?.footprint.date = datePicker.date
        }
        
        navigationController?.popViewControllerAnimated(true)
    }

}
