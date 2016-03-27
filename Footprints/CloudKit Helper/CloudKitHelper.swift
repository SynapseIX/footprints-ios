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
    
    
    // MARK: - Account methods
    
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
    
    // MARK: - Fetch methods
    
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
            
            if let favorite = record["favorite"] as? Int {
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
    
    class func fetchFootprintPicture(inout footprint: Footprint, completion: (error: NSError?) -> Void) {
        if footprint.picture == nil {
            let predicate = NSPredicate(format: "recordID == %@", footprint.recordID)
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            
            let query = CKQuery(recordType: "Footprint", predicate: predicate)
            query.sortDescriptors = [sortDescriptor]
            
            let operation = CKQueryOperation(query: query)
            operation.desiredKeys = ["picture"]
            
            operation.recordFetchedBlock = { record in
                if let asset = record["picture"] as? CKAsset {
                    footprint.picture = asset.fileURL
                }
            }
            
            operation.queryCompletionBlock = { cursor, error in
                completion(error: error)
            }
            
            database.addOperation(operation)
        }
    }
    
    class func fetchFootprintAudio(inout footprint: Footprint, completion: (error: NSError?) -> Void) {
        if footprint.audio == nil {
            let predicate = NSPredicate(format: "recordID == %@", footprint.recordID)
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            
            let query = CKQuery(recordType: "Footprint", predicate: predicate)
            query.sortDescriptors = [sortDescriptor]
            
            let operation = CKQueryOperation(query: query)
            operation.desiredKeys = ["audio"]
            
            operation.recordFetchedBlock = { record in
                if let asset = record["audio"] as? CKAsset {
                    footprint.audio = asset.fileURL
                }
            }
            
            operation.queryCompletionBlock = { cursor, error in
                completion(error: error)
            }
            
            database.addOperation(operation)
        }
    }
    
    // MARK: - Save methods
    
    class func saveFootprint(footprint: Footprint, completion:(record: CKRecord?, error: NSError?) -> Void) {
        if let recordID = footprint.recordID {
            database.fetchRecordWithID(recordID) { record, error in
                if error == nil {
                    if let fetchedRecord = record {
                        fetchedRecord["title"] = footprint.title
                        fetchedRecord["date"] = footprint.date ?? NSDate()
                        fetchedRecord["notes"] = footprint.notes
                        fetchedRecord["placeName"] = footprint.placeName
                        fetchedRecord["location"] = footprint.location
                        fetchedRecord["favorite"] = footprint.favorite
                        
                        if let picture = footprint.picture {
                            fetchedRecord["picture"] = CKAsset(fileURL: picture)
                        }
                        
                        if let audio = footprint.audio {
                            fetchedRecord["audio"] = CKAsset(fileURL: audio)
                        }
                        
                        database.saveRecord(fetchedRecord) { record, error in
                            completion(record: record, error: error)
                        }
                    }
                } else {
                    completion(record: record, error: error)
                }
            }
        } else {
            // TODO: this is a new footprint; create a new record and save it and add it to allFootprints
        }
    }
}
