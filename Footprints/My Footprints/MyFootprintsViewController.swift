//
//  MyFootprintsViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/24/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit
import CloudKit

let tableViewCellIdentifier = "ListCell"
let collectionViewCellIdentifier = "CollectionCell"

class MyFootprintsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingView: UIView!
    
    var gridButton: UIBarButtonItem!
    var listButton: UIBarButtonItem!
    var refreshControl: UIRefreshControl!
    
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
    
    // MARK: - Actions
    
    func gridAction(sender: AnyObject) {
        navigationItem.rightBarButtonItem = listButton
        
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
        
        UIView.animateWithDuration(0.5) {
            self.tableView.scrollsToTop = false
            self.collectionView.scrollsToTop = true
            self.collectionView.alpha = 1.0
        }
    }
    
    func listAction(sender: AnyObject) {
        navigationItem.rightBarButtonItem = gridButton
        
        UIView.animateWithDuration(0.5) {
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
        refreshControl.addTarget(self, action: #selector(MyFootprintsViewController.reloadData), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        // Removes search bar border
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = AppTheme.lightPinkColor
    }
    
    // MARK: - Data methods
    
    func reloadData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        CloudKitHelper.fetchAllFootprintsNoAssets { error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.data = CloudKitHelper.allFootprints
            
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.loadingView.hidden = true
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    
                    if self.refreshControl.refreshing {
                        self.refreshControl.endRefreshing()
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    if self.refreshControl.refreshing {
                        self.refreshControl.endRefreshing()
                    }
                    
                    AppError.handleAsAlert("Ooops!", message: error?.localizedDescription, presentingViewController: self, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Cell configuration methods
    
    func configureCell(cell: FootprintTableViewCell, indexPath: NSIndexPath) {
        var footprint = data[indexPath.row]
        
        cell.titleLabel.font = AppTheme.defaultMediumFont?.fontWithSize(16.0)
        cell.titleLabel.textColor = AppTheme.darkGrayColor
        cell.titleLabel.text = footprint.title
        
        cell.dateLabel.font = AppTheme.defaultFont?.fontWithSize(14.0)
        cell.dateLabel.textColor = AppTheme.darkGrayColor
        cell.dateLabel.text = AppUtils.formattedStringFromDate(footprint.date)
        
        cell.pictureImageView.image = UIImage(named: "default_picture")
        
        if let picture = footprint.picture {
            cell.pictureImageView?.image = UIImage(data: NSData(contentsOfURL: picture)!)
        } else {
            CloudKitHelper.fetchFootprintPicture(&footprint) { error in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        if let picture = footprint.picture {
                            cell.pictureImageView?.image = UIImage(data: NSData(contentsOfURL: picture)!)
                        } else {
                            cell.pictureImageView?.image = UIImage(named: "no_picture")
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        AppError.handleAsAlert("Ooops!", message: error?.localizedDescription, presentingViewController: self, completion: nil)
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
    }
    
    func configureCell(cell: UICollectionViewCell, indexPath: NSIndexPath, inout footprint: Footprint) {
        let imageView = cell.viewWithTag(1) as! UIImageView
        
        imageView.image = UIImage(named: "default_picture")
        
        if let picture = footprint.picture {
            imageView.image = UIImage(data: NSData(contentsOfURL: picture)!)
        } else {
            CloudKitHelper.fetchFootprintPicture(&footprint) { error in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        if let picture = footprint.picture {
                            imageView.image = UIImage(data: NSData(contentsOfURL: picture)!)
                        } else {
                            imageView.image = UIImage(named: "no_picture")
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        AppError.handleAsAlert("Ooops!", message: error?.localizedDescription, presentingViewController: self, completion: nil)
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
        
        tableView.reloadData()
        
        CloudKitHelper.saveFootprint(footprint) { record, error in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
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

}

// MARK: - Table view data source

extension MyFootprintsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfFootprints = data.count
        
        if numberOfFootprints > 0 {
            navigationItem.rightBarButtonItem?.enabled = true
            tableView.backgroundView = nil
        } else {
            navigationItem.rightBarButtonItem?.enabled = false
            
            let noContentImageView = UIImageView(image: UIImage(named: "no_content"))
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

extension MyFootprintsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let footprint = data[indexPath.row]
        
        // Keeps insets visible
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        // performSegueWithIdentifier("showDetailMainSegue", sender: footprint)
    }
    
}

// MARK: - Collection view data source

extension MyFootprintsViewController: UICollectionViewDataSource {
    
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

extension MyFootprintsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let footprint = data[indexPath.item]
        
        // performSegueWithIdentifier("showDetailMainSegue", sender: footprint)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = (UIScreen.mainScreen().bounds.size.width / 2.0)
        let height = width
        
        return CGSizeMake(width, height)
    }
    
}

// MARK: - Search bar delegate

extension MyFootprintsViewController: UISearchBarDelegate {
    
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
            data = CloudKitHelper.allFootprints
        }
        
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
