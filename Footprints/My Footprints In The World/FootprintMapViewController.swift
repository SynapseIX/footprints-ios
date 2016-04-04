//
//  FootprintMapViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/30/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit
import GoogleMaps

class FootprintMapViewController: UIViewController {
    
    @IBOutlet weak var myLocationButton: UIBarButtonItem!
    @IBOutlet weak var mapView: GMSMapView!
    
    var hasUserLocation = false
    var data = CloudKitHelper.allFootprints.filter {
        $0.location != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mapView.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
        myLocationButton.enabled = mapView.myLocation != nil
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadData()
        populateMap()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.removeObserver(self, forKeyPath: "myLocation")
        myLocationButton.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "myLocation" && object is GMSMapView {
            if !hasUserLocation {
                let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
                mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(myLocation.coordinate.latitude,
                    longitude: myLocation.coordinate.longitude, zoom: 0))
                myLocationButton.enabled = true
                
                hasUserLocation = true
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func myLocationAction(sender: AnyObject) {
        mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(mapView.myLocation!.coordinate.latitude,
            longitude: mapView.myLocation!.coordinate.longitude, zoom: 15))
    }
    
    // MARK: - Map methods

    private func setupMap() {
        mapView.delegate = self
        mapView.myLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.indoorPicker = true
    }
    
    private func populateMap() {
        mapView.clear()
        
        for footprint in data {
            let marker = GMSMarker(position: footprint.location!.coordinate)
            marker.icon = UIImage(named: "pin")
            marker.userData = footprint
            marker.tracksInfoWindowChanges = true
            marker.map = mapView
            
            // TODO: remove this when custom info windows work
            marker.title = footprint.title
            marker.snippet = AppUtils.formattedStringFromDate(footprint.date)
        }
    }
    
    private func reloadData() {
        data = CloudKitHelper.allFootprints.filter {
            $0.location != nil
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController as! UINavigationController
        let detailTableViewController = destinationViewController.topViewController as! DetailTableViewController
        
        detailTableViewController.footprint = sender as! Footprint
    }

}

// MARK: - Map view delegate

extension FootprintMapViewController: GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let footprint = marker.userData as! Footprint
        
        let infoWindowContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 242, height: 50))
        infoWindowContainerView.backgroundColor = UIColor.whiteColor()
        
        let pictureImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        pictureImageView.contentMode = .ScaleAspectFill
        
        if let picture = footprint.picture {
            pictureImageView.image = UIImage(data: NSData(contentsOfURL: picture)!)
        } else {
            pictureImageView.image = UIImage(named: "no_picture")
        }
        
        let titleLabel = UILabel(frame: CGRect(x: 58, y: 6, width: 176, height: 20))
        titleLabel.textColor = AppTheme.darkGrayColor
        titleLabel.font = AppTheme.defaultMediumFont?.fontWithSize(14.0)
        titleLabel.text = footprint.title
        
        let dateLabel = UILabel(frame: CGRect(x: 58, y: 26, width: 176, height: 17))
        dateLabel.textColor = AppTheme.darkGrayColor
        dateLabel.font = AppTheme.defaultFont?.fontWithSize(12.0)
        dateLabel.text = AppUtils.formattedStringFromDate(footprint.date)
        
        infoWindowContainerView.addSubview(pictureImageView)
        infoWindowContainerView.addSubview(titleLabel)
        infoWindowContainerView.addSubview(dateLabel)
        
        return infoWindowContainerView
        
        // TODO: enable when Google fixes their stuff
//        let infoWindow = NSBundle.mainBundle().loadNibNamed("InfoWindow", owner: self, options: nil).first as! InfoWindow
//        infoWindow.pictureImageView.image = UIImage(named: "no_picture")
//        infoWindow.titleLabel.text = footprint.title
//        infoWindow.dateLabel.text = AppUtils.formattedStringFromDate(footprint.date)
//        
//        return infoWindow
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        let footprint = marker.userData as! Footprint
        performSegueWithIdentifier("showDetailMapSegue", sender: footprint)
    }
    
}
