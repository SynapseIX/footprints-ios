//
//  CloudKitHelper.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/24/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit
import CloudKit

class CloudKitHelper {

    private static let database = CKContainer.defaultContainer().privateCloudDatabase;
    static var allFootprints = [Footprint]()
    
    class func checkAccountStatus(onAvailable: () -> Void, onNoAccount: () -> Void, onRestricted: () -> Void, onError: (error: NSError?) -> Void) {
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { accountStatus, error in
            if error == nil {
                switch accountStatus {
                case .Available:
                    onAvailable()
                case .NoAccount:
                    onNoAccount()
                case .Restricted:
                    onRestricted()
                    break
                default:
                    break
                }
            } else {
                onError(error: error)
            }
        }
    }
    
    class func fetchAllFootprintsNoAssets(completion: (error: NSError?) -> Void) {
        let predicate = NSPredicate(value: true)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        let query = CKQuery(recordType: "Footprint", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["title", "notes", "placeName", "location", "date", "favorite"]
        
        var fetchedFootprints = [Footprint]()
        
        operation.recordFetchedBlock = { record in
            let footprint = Footprint()
            footprint.recordID = record.recordID
            footprint.title = record["title"] as! String
            footprint.notes = record["notes"] as? String
            footprint.placeName = record["placeName"] as? String
            footprint.location = record["location"] as? CLLocation
            footprint.date = record["date"] as! NSDate
            
            if let favorite = record["favorite"] as? Bool {
                footprint.favorite = favorite
            }
            
            fetchedFootprints.append(footprint)
        }
        
        operation.queryCompletionBlock = { cursor, error in
            let theFootprints = fetchedFootprints
            allFootprints = theFootprints
            
            completion(error: error)
        }
        
        database.addOperation(operation)
    }
    
    class func fetchFootprintsPictures(completion: (error: NSError?) -> Void) {
        let predicate = NSPredicate(value: true)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    
        let query = CKQuery(recordType: "Footprint", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
    
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["picture"]
        
        operation.recordFetchedBlock = { record in
            if let footprint = allFootprints.filter({$0.recordID == record.recordID}).first {
                let asset = record["picture"] as! CKAsset
                footprint.picture = asset.fileURL
            }
        }
        
        operation.queryCompletionBlock = { cursor, error in
            completion(error: error)
        }
        
        database.addOperation(operation)
    }
}
