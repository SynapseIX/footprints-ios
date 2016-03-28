//
//  CreateFootprintTableViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/28/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class CreateFootprintTableViewController: UITableViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var addTitleLabel: UILabel!
    @IBOutlet weak var addTextNoteLabel: UILabel!
    @IBOutlet weak var addPlaceLabel: UILabel!
    @IBOutlet weak var addDateLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    var footprint = Footprint()
    
    var audioSession: AVAudioSession!
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        saveButton.enabled = footprint.title != nil
        // TODO: implement
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK : - Actions
    
    @IBAction func dismissAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        tableView.setContentOffset(CGPointZero, animated: true)
        // TODO: complete
    }
    
    // MARK: - UI methods
    private func setupUI() {
        clearsSelectionOnViewWillAppear = true
        saveButton.enabled = false
        
        // Remove navigation bar border
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = AppTheme.tableVieCellSelectionColor
        
        for section in 0...tableView.numberOfSections - 1 {
            for row in 0...tableView.numberOfRowsInSection(section) - 1 {
                let indexPath = NSIndexPath(forRow: row, inSection: section)
                
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                cell?.selectedBackgroundView = selectedBackgroundView
            }
        }
        
        // Change this navigation controller only
        navigationController?.navigationBar.barTintColor = AppTheme.darkGrayColor
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: implement
        NSLog("Selected section \(indexPath.section), row \(indexPath.row)...")
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor.lightTextColor()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        // TODO: implement
    }
    
}

// Image picker controller delegate

extension CreateFootprintTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // TODO: implement
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true) {
            self.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2), animated: true)
            self.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 2), animated: true)
            
            self.view.setNeedsDisplay()
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
}

// MARK: - Audio player delegate

extension CreateFootprintTableViewController: AVAudioPlayerDelegate {
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        do {
            try audioSession.setActive(false)
        } catch {
            let error = error as NSError
            NSLog("\(error), \(error.userInfo)")
        }
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer, withFlags flags: Int) {
        if flags == AVAudioSessionInterruptionFlags_ShouldResume {
            player.play()
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        do {
            try audioSession.setActive(false)
            audioSession = nil
            audioPlayer = nil
        } catch {
            let error = error as NSError
            NSLog("\(error), \(error.userInfo)")
        }
    }

}
