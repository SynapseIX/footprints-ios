//
//  DetailTableViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 4/4/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import GoogleMaps

class DetailTableViewController: UITableViewController {

    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var addTitleLabel: UILabel!
    @IBOutlet weak var addTextNoteLabel: UILabel!
    @IBOutlet weak var addPlaceCell: UITableViewCell!
    @IBOutlet weak var addPlaceLabel: UILabel!
    @IBOutlet weak var addDateLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var loadingPictureView: UIActivityIndicatorView!
    
    var footprint: Footprint!
    
    var userPicture: UIImage?
    var audioSession: AVAudioSession!
    var audioPlayer: AVAudioPlayer!
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkForLocationAccess()
        
        saveButton.enabled = footprint.title != nil
        
        if footprint.picture == nil {
            CloudKitHelper.fetchFootprintPicture(footprint.recordID) { (picture) in
                if let picture = picture {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.userPicture = UIImage(data: NSData(contentsOfURL: picture)!)
                        self.pictureImageView.image = self.userPicture
                        self.tableView.reloadData()
                    }
                }
            }
        } else {
            loadingPictureView.stopAnimating()
        }
        
        if footprint.notes != nil {
            addTextNoteLabel.text = footprint.notes
        } else {
            addTextNoteLabel.text = "Write some notes"
        }
        
        if footprint.placeName != nil {
            addPlaceLabel.text = footprint.placeName!
        } else {
            addPlaceLabel.text = "Add that special place"
        }
        
        if footprint.date != nil {
            addDateLabel.text = AppUtils.formattedStringFromDate(footprint.date!)
        } else {
            addDateLabel.text = "Add a date to remember"
        }
        
        if footprint.audio == nil {
            CloudKitHelper.fetchFootprintAudio(footprint.recordID) { (audio) in
                if let audio = audio {
                    self.footprint.audio = audio;
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func dismissAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        tableView.setContentOffset(CGPointZero, animated: true)
        
        footprint.date = footprint.date ?? NSDate()
        
        // Process photo
        var imageFilePath: NSURL?
        
        if userPicture != nil {
            imageFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("\(NSUUID().UUIDString).igo")
            UIImageJPEGRepresentation(userPicture!, 1.0)?.writeToFile(imageFilePath!.relativePath!, atomically: true)
            footprint.picture = imageFilePath
        }
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.frame = CGRect(x: (UIScreen.mainScreen().bounds.width / 2.0) - (activityIndicator.frame.width / 2.0), y: (UIScreen.mainScreen().bounds.height / 2.0) - activityIndicator.frame.height - 64.0, width: activityIndicator.frame.width, height: activityIndicator.frame.height)
        activityIndicator.color = AppTheme.lightPinkColor
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        view.userInteractionEnabled = false
        saveButton.enabled = false
        dismissButton.enabled = false
        
        CloudKitHelper.saveFootprint(footprint) { record, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if error == nil {
                self.footprint.recordID = record?.recordID
                self.footprint.picture = nil
                
                AppUtils.deleteFile(imageFilePath)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.saveButton.enabled = true
                    self.dismissButton.enabled = true
                    self.view.userInteractionEnabled = true
                    activityIndicator.removeFromSuperview()
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.saveButton.enabled = true
                    self.dismissButton.enabled = true
                    self.view.userInteractionEnabled = true
                    activityIndicator.removeFromSuperview()
                    
                    AppError.handleAsAlert("Ooops!", message: error?.localizedDescription, presentingViewController: self, completion: nil)
                }
            }
        }
    }
    
    // MARK: - UI methods
    
    private func setupUI() {
        title = footprint.title
        
        if footprint.picture != nil {
            pictureImageView.image = UIImage(data: NSData(contentsOfURL: footprint.picture!)!)
        }
        
        clearsSelectionOnViewWillAppear = true
        saveButton.enabled = false
        
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
        
        // Remove navigation bar border
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        // Initialize add places UI
        addPlaceCell.userInteractionEnabled = false
        addPlaceLabel.textColor = AppTheme.disabledColor
        
        // Setup refresh control
        refreshControl = UIRefreshControl()
        refreshControl!.backgroundColor = AppTheme.darkGrayColor
        refreshControl!.tintColor = UIColor.whiteColor()
        refreshControl!.addTarget(self, action: #selector(DetailTableViewController.refresh), forControlEvents: .ValueChanged)
    }
    
    func refresh() {
        tableView.reloadData()
        
        if refreshControl!.refreshing {
            refreshControl!.endRefreshing()
        }
    }
    
    // MARK: - Location manager methods
    
    private func setupLocationManager() {
        locationManager = locationManager ?? CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    private func checkForLocationAccess() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus {
        case .NotDetermined:
            requestLocationAccess()
        case .Denied:
            handleLocationAccess(false)
        case .AuthorizedWhenInUse:
            handleLocationAccess(true)
        default:
            break
        }
    }
    
    private func requestLocationAccess() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func handleLocationAccess(authorized: Bool) {
        if authorized {
            setupLocationManager()
        } else {
            AppError.handleAsAlert("Ooops!", message: "Footprints needs to access your location to determine places you are and places you were.", presentingViewController: self, completion: nil)
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            presentTakeOrChoosePictureAlertController(indexPath)
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            presentNameFootprintAlertController(indexPath)
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 1 {
                if footprint.location == nil {
                    presentPlacePicker(indexPath)
                } else {
                    presentManagePlaceAlertController(indexPath)
                }
            }
        }
        
        if indexPath.section == 3 {
            if indexPath.row == 0 {
                if footprint.audio != nil {
                    presentRecordAudioAlertController(indexPath)
                } else {
                    performSegueWithIdentifier("recordAudioDetailSegue", sender: nil)
                }
            }
        }
        
        if indexPath.section == 4 && indexPath.row == 0 {
            presentDeleteFootprintAlertController(indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if footprint.picture != nil {
                pictureImageView.hidden = false
                pictureImageView.image = UIImage(data: NSData(contentsOfURL: footprint.picture!)!)
                return UIScreen.mainScreen().bounds.size.width
            } else {
                pictureImageView.hidden = true
                return 44.0
            }
        }
        
        return 44.0
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        if destinationViewController is RecordAudioViewController {
            (destinationViewController as! RecordAudioViewController).delegate = self
        }
        
        if destinationViewController is TextNoteViewController {
            (destinationViewController as! TextNoteViewController).delegate = self
        }
        
        if destinationViewController is SelectDateViewController {
            (destinationViewController as! SelectDateViewController).delegate = self
        }
    }
    
    // MARK: - Name footprint methods
    
    private func presentNameFootprintAlertController(indexPath: NSIndexPath) {
        weak var weakSelf = self
        
        let alert = UIAlertController(title: "Name your Footprint", message: nil, preferredStyle: .Alert)
        
        let addAction = UIAlertAction(title: "Name It", style: .Cancel) { action in
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                weakSelf?.footprint.title = alert.textFields?.first?.text
                weakSelf?.addTitleLabel.text = weakSelf?.footprint.title
                weakSelf?.title = weakSelf?.footprint.title
                weakSelf?.saveButton.enabled = true
            }
        }
        addAction.enabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { action in
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.autocapitalizationType = .Words
            textField.spellCheckingType = .Yes
            textField.autocorrectionType = .Yes
            textField.placeholder = "My Most Amazing Moment"
            textField.text = self.footprint.title
            textField.keyboardAppearance = .Dark
            textField.clearButtonMode = .WhileEditing
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                addAction.enabled = textField.text?.characters.count > 0
            }
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Take or choose picture methods
    
    private func presentTakeOrChoosePictureAlertController(indexPath: NSIndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.view.tintColor = AppTheme.disabledColor
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .Default) { action in
            let imagePickerController = UIImagePickerController()
            imagePickerController.navigationBar.barTintColor = AppTheme.darkGrayColor
            imagePickerController.delegate = self
            imagePickerController.sourceType = .PhotoLibrary
            imagePickerController.mediaTypes = [String(kUTTypeImage)]
            imagePickerController.allowsEditing = true
            
            self.presentViewController(imagePickerController, animated: true) {
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        
        let takeAction = UIAlertAction(title: "Take Photo", style: .Default) { action in
            let imagePickerController = UIImagePickerController()
            imagePickerController.navigationBar.barTintColor = AppTheme.darkGrayColor
            imagePickerController.delegate = self
            imagePickerController.sourceType = .Camera
            imagePickerController.mediaTypes = [String(kUTTypeImage)]
            imagePickerController.allowsEditing = true
            
            self.presentViewController(imagePickerController, animated: true) {
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .Destructive) { action in
            self.userPicture = nil
            self.pictureImageView.image = UIImage(named: "camera")
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        if pictureImageView.image != nil {
            alert.addAction(removeAction)
        }
        
        alert.addAction(cancelAction)
        
        if PHPhotoLibrary.authorizationStatus() == .Authorized || PHPhotoLibrary.authorizationStatus() == .NotDetermined {
            alert.addAction(libraryAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alert.addAction(takeAction)
        }
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Record audio methods
    
    private func presentRecordAudioAlertController(indexPath: NSIndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.view.tintColor = AppTheme.disabledColor
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        let recordAction = UIAlertAction(title: "Record", style: .Default) { action in
            self.performSegueWithIdentifier("recordAudioDetailSegue", sender: nil)
        }
        
        let playAction = UIAlertAction(title: "Play", style: .Default) { action in
            dispatch_async(dispatch_get_main_queue()) {
                do {
                    self.audioSession = AVAudioSession.sharedInstance()
                    try self.audioSession.setActive(true)
                    try self.audioSession.setCategory(AVAudioSessionCategoryPlayback, withOptions: .DuckOthers)
                    
                    let audioData = try NSData(contentsOfURL: self.footprint.audio!, options: .MappedRead)
                    
                    self.audioPlayer = try AVAudioPlayer(data: audioData)
                    self.audioPlayer.delegate = self
                    self.audioPlayer.play()
                } catch {
                    NSLog("\(error)")
                }
            }
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .Destructive) { action in
            self.footprint.audio = nil
        }
        
        alert.addAction(cancelAction)
        
        if self.footprint.audio != nil {
            alert.addAction(removeAction)
            alert.addAction(playAction)
        }
        
        alert.addAction(recordAction)
        
        presentViewController(alert, animated: true, completion: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Add place methods
    
    private func presentPlacePicker(indexPath: NSIndexPath) {
        if userLocation != nil {
            let northEast = CLLocationCoordinate2DMake(userLocation.coordinate.latitude + 0.001, userLocation.coordinate.longitude + 0.001)
            let southWest = CLLocationCoordinate2DMake(userLocation.coordinate.latitude - 0.001, userLocation.coordinate.longitude - 0.001)
            
            let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let config = GMSPlacePickerConfig(viewport: viewport)
            
            let placePicker = GMSPlacePicker(config: config)
            placePicker.pickPlaceWithCallback { (place, error) in
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        AppError.handleAsAlert("Ooops!", message: error.localizedDescription, presentingViewController: self, completion: nil)
                    }
                    
                    return
                }
                
                if let place = place {
                    self.footprint.placeName = place.name
                    self.footprint.location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.addPlaceLabel.text = self.footprint.placeName
                    }
                }
            }
        } else {
            AppError.handleAsAlert("Ooops!", message: "Footprints needs to access your location to determine places you are and places you were.", presentingViewController: self, completion: nil)
        }
    }
    
    private func presentManagePlaceAlertController(indexPath: NSIndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.view.tintColor = AppTheme.disabledColor
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .Destructive) { action in
            self.footprint.placeName = nil
            self.footprint.location = nil
            
            self.addPlaceLabel.text = "Add that special place"
        }
        
        let selectPlaceAction = UIAlertAction(title: "Select New Place", style: .Default) { action in
            self.presentPlacePicker(indexPath)
        }
        
        alert.addAction(removeAction)
        alert.addAction(cancelAction)
        alert.addAction(selectPlaceAction)
        
        presentViewController(alert, animated: true) {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    // MARK: - Delete footprint methods
    
    private func presentDeleteFootprintAlertController(indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Delete Footprint", message: "Do you REALLY want to delete your footprint \"\(footprint.title)\" and all media files associated to it? This action CANNOT be undone, proceed with caution.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { action in
            CloudKitHelper.deleteFootprint(self.footprint.recordID) { (error) in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        AppError.handleAsAlert("Error", message: error.localizedDescription, presentingViewController: self, completion: nil)
                    }
                    
                    return
                }
                
                let index = CloudKitHelper.allFootprints.indexOf {
                    $0.recordID == self.footprint.recordID
                }
                
                if let index = index {
                    CloudKitHelper.allFootprints.removeAtIndex(index)
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        presentViewController(alert, animated: true, completion: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}

// MARK: - Image picker controller delegate

extension DetailTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        userPicture = info[UIImagePickerControllerEditedImage] as? UIImage
        pictureImageView.image = userPicture
        
        picker.dismissViewControllerAnimated(true) {
            self.view.setNeedsDisplay()
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
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

extension DetailTableViewController: AVAudioPlayerDelegate {
    
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

// MARK: - Location manager delegate

extension DetailTableViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        addPlaceCell.userInteractionEnabled = true
        addPlaceLabel.textColor = UIColor.whiteColor()
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        weak var weakSelf = self
        
        if status == .AuthorizedWhenInUse {
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.handleLocationAccess(true)
            }
        }
        
        if status == .Denied {
            dispatch_async(dispatch_get_main_queue()) {
                weakSelf?.handleLocationAccess(false)
            }
        }
    }
    
}