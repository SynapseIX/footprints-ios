//
//  SettingsTableViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 4/2/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var deleteCell: UITableViewCell!
    @IBOutlet weak var deleteLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if CloudKitHelper.allFootprints.count > 0 {
            deleteCell.selectionStyle = .Default
            deleteCell.userInteractionEnabled = true
            
            deleteLabel.textColor = AppTheme.redColor
        } else {
            deleteCell.selectionStyle = .None
            deleteCell.userInteractionEnabled = false
            
            deleteLabel.textColor = AppTheme.disabledColor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupUI() {
        self.clearsSelectionOnViewWillAppear = true
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = AppTheme.tableVieCellSelectionColor
        
        for section in 0...tableView.numberOfSections - 1 {
            for row in 0...tableView.numberOfRowsInSection(section) - 1 {
                let indexPath = NSIndexPath(forRow: row, inSection: section)
                
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                cell?.selectedBackgroundView = selectedBackgroundView
            }
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    private func presentDeleteAllFootprintsAlertController() {
        let numberOfFootprints = CloudKitHelper.allFootprints.count
        
        let alert = UIAlertController(title: "Delete All Footprints", message: "Do you REALLY want to delete all your footprints and all media files associated to them? Are you absolutely sure you want to delete \(numberOfFootprints)? This action CANNOT be undone, proceed with caution.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { action in
            CloudKitHelper.deleteAllFootprints { (error) in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        AppError.handleAsAlert("Error", message: error.localizedDescription, presentingViewController: self, completion: nil)
                    }
                    
                    return
                }
                
                CloudKitHelper.allFootprints.removeAll()
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.deleteCell.selectionStyle = .None
                    self.deleteCell.userInteractionEnabled = false
                    self.deleteLabel.textColor = AppTheme.disabledColor
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                UIApplication.sharedApplication().openURL(NSURL(string: "http://github.com/itsProf")!)
            } else if indexPath.row == 1 {
                UIApplication.sharedApplication().openURL(NSURL(string: "http://twitter.com/itsProf")!)
            } else if indexPath.row == 2 {
                UIApplication.sharedApplication().openURL(NSURL(string: "http://jorgetapia.net")!)
            }
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                presentDeleteAllFootprintsAlertController()
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
