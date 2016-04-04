//
//  MyFavoriteFootprintsViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/27/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit
import Social

class MyFavoriteFootprintsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingView: UIView!
    
    var gridButton: UIBarButtonItem!
    var listButton: UIBarButtonItem!
    var refreshControl: UIRefreshControl!
    
    var fileToShare: NSURL?
    var documentInteractionController: UIDocumentInteractionController!
    
    var data = [Footprint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        AppUtils.deleteFile(fileToShare)
    }
    
    // MARK: - Actions
    
    func gridAction(sender: AnyObject) {
        navigationItem.rightBarButtonItem = listButton
        
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
        
        UIView.animateWithDuration(1.0) {
            self.tableView.scrollsToTop = false
            self.collectionView.scrollsToTop = true
            self.collectionView.alpha = 1.0
        }
    }
    
    func listAction(sender: AnyObject) {
        navigationItem.rightBarButtonItem = gridButton
        
        UIView.animateWithDuration(1.0) {
            self.collectionView.scrollsToTop = false
            self.tableView.scrollsToTop = true
            self.collectionView.alpha = 0.0
        }
    }
    
    // MARK: - UI Methods
    
    func setupUI() {
        tableView.estimatedRowHeight = 320.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.setContentOffset(CGPointMake(0, 44), animated: false)
        tableView.registerNib(UINib(nibName: "FootprintTableViewCell", bundle: nil), forCellReuseIdentifier: tableViewCellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Setup footprint tab bar item
        // TODO: uncomment once implemented
        /*let tabBarItemImage = UIImage(named: "footprints_tab")?.imageWithRenderingMode(.AlwaysOriginal)
         let footprintTabBarItem = tabBarController?.tabBar.items?[2]
         
         footprintTabBarItem?.selectedImage = tabBarItemImage
         footprintTabBarItem?.image = tabBarItemImage*/
        
        // Remove navigation bar border
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        
        // Setup right navigation item right bar button item
        gridButton = UIBarButtonItem(image: UIImage(named: "grid"), style: .Plain, target: self, action: #selector(MyFootprintsViewController.gridAction(_:)))
        
        listButton = UIBarButtonItem(image: UIImage(named: "list"), style: .Plain, target: self, action: #selector(MyFootprintsViewController.listAction(_:)))
        
        navigationItem.rightBarButtonItem = gridButton
        
        // Setup refresh control
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = AppTheme.lightPinkColor
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: #selector(MyFavoriteFootprintsViewController.reloadData), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        // Removes search bar border
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = AppTheme.lightPinkColor
    }
    
    // MARK: - Data methods
    
    func reloadData() {
        data = CloudKitHelper.allFootprints.filter {
            $0.favorite == 1
        }
        
        loadingView.hidden = true
        tableView.reloadData()
        collectionView.reloadData()
        
        if refreshControl.refreshing {
            refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Cell configuration methods
    
    func configureCell(cell: FootprintTableViewCell, indexPath: NSIndexPath) {
        let footprint = data[indexPath.row]
        
        cell.titleLabel.font = AppTheme.defaultMediumFont?.fontWithSize(16.0)
        cell.titleLabel.textColor = AppTheme.disabledColor
        cell.titleLabel.text = footprint.title
        
        cell.dateLabel.font = AppTheme.defaultFont?.fontWithSize(14.0)
        cell.dateLabel.textColor = AppTheme.disabledColor
        cell.dateLabel.text = AppUtils.formattedStringFromDate(footprint.date)
        
        cell.pictureImageView.image = UIImage(named: "default_picture")
        
        if let picture = footprint.picture {
            cell.pictureImageView?.image = UIImage(data: NSData(contentsOfURL: picture)!)
        } else {
            CloudKitHelper.fetchFootprintPicture(footprint.recordID) { picture in
                if let picture = picture {
                    footprint.picture = picture
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.pictureImageView.image = UIImage(data: NSData(contentsOfURL: footprint.picture!)!)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.pictureImageView.image = UIImage(named: "no_picture")
                    }
                }
            }
        }
        
        if footprint.favorite == 1 {
            cell.favoriteButton.setImage(UIImage(named: "favorite_selected"), forState: .Normal)
        } else {
            cell.favoriteButton.setImage(UIImage(named: "favorite_not_selected"), forState: .Normal)
        }
        
        cell.favoriteButton.addTarget(self, action: #selector(MyFootprintsViewController.favoriteFootprint(_:)), forControlEvents: .TouchUpInside)
        
        cell.shareButton.hidden = footprint.picture == nil ? true : false
        cell.shareButton.addTarget(self, action: #selector(MyFootprintsViewController.shareFootprint(_:)), forControlEvents: .TouchUpInside)
    }
    
    func configureCell(cell: UICollectionViewCell, indexPath: NSIndexPath, inout footprint: Footprint) {
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: "default_picture")
        
        if let picture = footprint.picture {
            imageView.image = UIImage(data: NSData(contentsOfURL: picture)!)
        } else {
            CloudKitHelper.fetchFootprintPicture(footprint.recordID) { picture in
                if let picture = picture {
                    footprint.picture = picture
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        imageView.image = UIImage(data: NSData(contentsOfURL: footprint.picture!)!)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        imageView.image = UIImage(named: "no_picture")
                    }
                }
            }
        }
    }
    
    // MARK: - Favorite handler
    
    func favoriteFootprint(sender: UIButton) {
        let buttonPointOnTableView = sender.convertPoint(CGPointZero, toView: tableView)
        let indexPath = tableView.indexPathForRowAtPoint(buttonPointOnTableView)
        let footprint = data[indexPath!.row]
        
        if footprint.favorite == 1 {
            footprint.favorite = 0
            sender.setImage(UIImage(named: "favorite_not_selected"), forState: .Normal)
        } else {
            footprint.favorite = 1
            sender.setImage(UIImage(named: "favorite_selected"), forState: .Normal)
        }
        
        reloadData()
        
        CloudKitHelper.saveFootprint(footprint) { record, error in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.reloadData()
                }
            } else {
                if error!.code != 14 {
                    AppError.handleAsAlert("Error", message: error!.localizedDescription, presentingViewController: self, completion: nil)
                } else {
                    NSLog("\(error), \(error!.userInfo)")
                }
            }
        }
    }
    
    // MARK: - Share handler
    
    func shareFootprint(sender: UIButton) {
        let buttonPointOnTableView = sender.convertPoint(CGPointZero, toView: tableView)
        let indexPath = tableView.indexPathForRowAtPoint(buttonPointOnTableView)
        let footprint = data[indexPath!.row]
        
        // Facebook action
        let alert = UIAlertController(title: footprint.title, message: "Where do you want to share your footprint?", preferredStyle: .ActionSheet)
        
        let facebookAction = UIAlertAction(title: "Facebook", style: .Default) { action in
            let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                composeViewController.completionHandler = { result in
                    if result == .Done {
                        NSLog("Successfully shared on Facebook.")
                    }
                }
                
                let pictureImage = UIImage(contentsOfFile: footprint.picture!.relativePath!)
                composeViewController.addImage(pictureImage!)
                
                self.presentViewController(composeViewController, animated: true, completion: nil)
            } else {
                AppError.handleAsAlert("Sign in to Facebook", message: "You are not signed in with Facebook. On the Home screen, launch Settings, tap Facebook, and sign in to your account.", presentingViewController: self, completion: nil)
            }
        }
        
        let facebookImage = UIImage(named: "facebook")!.imageWithRenderingMode(.AlwaysOriginal)
        facebookAction.setValue(facebookImage, forKey: "image")
        
        alert.addAction(facebookAction)
        
        // Twitter action
        let twitterAction = UIAlertAction(title: "Twitter", style: .Default) { action in
            let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                composeViewController.completionHandler = { result in
                    if result == .Done {
                        NSLog("Successfully shared on Twitter.")
                    }
                }
                
                composeViewController.setInitialText(AppUtils.twitterfyString("\(footprint.title) #FootprintsApp"))
                composeViewController.addURL(AppUtils.appStoreURL)
                
                let pictureImage = UIImage(contentsOfFile: footprint.picture!.relativePath!)
                composeViewController.addImage(pictureImage!)
                
                self.presentViewController(composeViewController, animated: true, completion: nil)
            } else {
                AppError.handleAsAlert("Sign in to Twitter", message: "You are not signed in with Twitter. On the Home screen, launch Settings, tap Twitter, and sign in to your account.", presentingViewController: self, completion: nil)
            }
        }
        
        let twitterImage = UIImage(named: "twitter")!.imageWithRenderingMode(.AlwaysOriginal)
        twitterAction.setValue(twitterImage, forKey: "image")
        
        alert.addAction(twitterAction)
        
        // Instagram action
        let instagramAction = UIAlertAction(title: "Instagram", style: .Default) { action in
            let instagramURL = NSURL(string: "instagram://app")!
            
            if UIApplication.sharedApplication().canOpenURL(instagramURL) {
                let buttonPointOnTableView = sender.convertPoint(CGPointZero, toView: self.tableView)
                let indexPath = self.tableView.indexPathForRowAtPoint(buttonPointOnTableView)
                let footprint = self.data[indexPath!.row]
                
                self.fileToShare = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("\(footprint.recordID.recordName).igo")
                
                if let fileToShare = self.fileToShare {
                    let shareImage = UIImage(contentsOfFile: footprint.picture!.relativePath!)
                    UIImageJPEGRepresentation(shareImage!, 1.0)?.writeToFile(fileToShare.relativePath!, atomically: true)
                    
                    self.documentInteractionController = UIDocumentInteractionController(URL: fileToShare)
                    self.documentInteractionController.UTI = "com.instagram.exclusivegram"
                    
                    self.documentInteractionController.presentOpenInMenuFromRect(CGRectZero, inView: self.view, animated: true)
                }
            } else {
                AppError.handleAsAlert("Instagram Not Installed", message: "Instagram is not installed. To share your footprints on Instagram, download the app from the App Store.", presentingViewController: self, completion: nil)
            }
        }
        
        let instagramImage = UIImage(named: "instagram")!.imageWithRenderingMode(.AlwaysOriginal)
        instagramAction.setValue(instagramImage, forKey: "image")
        
        alert.addAction(instagramAction)
        
        // Cancel Action
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        
        alert.view.tintColor = AppTheme.disabledColor
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        searchBar.text = nil
        
        let destinationViewController = segue.destinationViewController as! UINavigationController
        let detailTableViewController = destinationViewController.topViewController as! DetailTableViewController
        
        detailTableViewController.footprint = sender as! Footprint
    }
    
}

// MARK: - Table view data source

extension MyFavoriteFootprintsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfFootprints = data.count
        
        if numberOfFootprints > 0 {
            navigationItem.rightBarButtonItem?.enabled = true
            tableView.backgroundView = nil
        } else {
            navigationItem.rightBarButtonItem?.enabled = false
            
            let noContentImageView = UIImageView(image: UIImage(named: "no_favorites"))
            noContentImageView.contentMode = .ScaleAspectFit
            noContentImageView.backgroundColor = UIColor.whiteColor()
            
            tableView.backgroundView = noContentImageView
        }
        
        return numberOfFootprints
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier, forIndexPath: indexPath) as! FootprintTableViewCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
}

// MARK: - Table view delegate

extension MyFavoriteFootprintsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let footprint = data[indexPath.row]
        
        // Keeps insets visible
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        performSegueWithIdentifier("showDetailFavoriteSegue", sender: footprint)
    }
    
}

// MARK: - Collection view data source

extension MyFavoriteFootprintsViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var footprint = data[indexPath.item]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionViewCellIdentifier, forIndexPath: indexPath)
        
        configureCell(cell, indexPath: indexPath, footprint: &footprint)
        
        return cell
    }
    
}


// MARK: - Collection view delegate

extension MyFavoriteFootprintsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let footprint = data[indexPath.item]
        performSegueWithIdentifier("showDetailFavoriteSegue", sender: footprint)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = (UIScreen.mainScreen().bounds.size.width / 2.0)
        let height = width
        
        return CGSizeMake(width, height)
    }
    
}

// MARK: - Search bar delegate

extension MyFavoriteFootprintsViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            data = data.filter {
                let theSearch = searchText.lowercaseString
                let title = $0.title.lowercaseString
                let notes = $0.notes?.lowercaseString
                let placeName = $0.placeName?.lowercaseString
                
                return title.containsString(theSearch) || (notes != nil && notes!.containsString(theSearch)) || (placeName != nil && placeName!.containsString(theSearch))
            }
        } else {
            data = CloudKitHelper.allFootprints.filter {
                $0.favorite == 1
            }
        }
        
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}