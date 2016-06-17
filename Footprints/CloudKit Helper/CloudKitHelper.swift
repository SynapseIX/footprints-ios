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
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (accountStatus, error) in
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
        checkAccountStatus({
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
            
            operation.queryCompletionBlock = { (cursor, error) in
                let theFootprints = fetchedFootprints
                allFootprints = theFootprints
                
                completion(error: error)
            }
            
            database.addOperation(operation)
        }, onNoAccount: {
            completion(error: NSError(domain: "iCloud", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sign in to your iCloud account to start using Footprints. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on. If you don't have an iCloud account, tap Create a new Apple ID."]))
        }, onRestricted: {
            completion(error: NSError(domain: "iCloud", code: -2, userInfo: [NSLocalizedDescriptionKey: "iCloud access is restricted by parental controls. Please ask your guardian to disable iCloud restrictions."]))
        }) { (error) in
            if let error = error {
                completion(error: error)
            }
        }
    }
    
    class func fetchFootprintPicture(recordID: CKRecordID, completion: (picture: NSURL?) -> Void) {
        let predicate = NSPredicate(format: "recordID == %@", recordID)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        let query = CKQuery(recordType: "Footprint", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["picture"]
        
        operation.recordFetchedBlock = { (record) in
            let asset = record["picture"] as? CKAsset
            completion(picture: asset?.fileURL)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            if let error = error {
                AppError.handleAsLog(error.description)
            }
        }
        
        database.addOperation(operation)
    }
    
    class func fetchFootprintAudio(recordID: CKRecordID, completion: (audio: NSURL?) -> Void) {
        let predicate = NSPredicate(format: "recordID == %@", recordID)
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        let query = CKQuery(recordType: "Footprint", predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["audio"]
        
        operation.recordFetchedBlock = { (record) in
            let asset = record["audio"] as? CKAsset
            completion(audio: asset?.fileURL)
        }
        
        operation.queryCompletionBlock = { cursor, error in
            if let error = error {
                AppError.handleAsLog(error.description)
            }
        }
        
        database.addOperation(operation)
    }
    
    // MARK: - Save methods
    
    class func saveFootprint(footprint: Footprint, completion:(record: CKRecord?, error: NSError?) -> Void) {
        if let recordID = footprint.recordID {
            database.fetchRecordWithID(recordID) { (record, error) in
                if error == nil {
                    if let fetchedRecord = record {
                        fetchedRecord["title"] = footprint.title
                        fetchedRecord["date"] = footprint.date
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
            let recordID = CKRecordID(recordName: NSUUID().UUIDString)
            
            let record = CKRecord(recordType: "Footprint", recordID: recordID)
            record["title"] = footprint.title
            record["date"] = footprint.date
            record["notes"] = footprint.notes
            record["placeName"] = footprint.placeName
            record["location"] = footprint.location
            record["favorite"] = footprint.favorite
            
            if let picture = footprint.picture {
                record["picture"] = CKAsset(fileURL: picture)
            }
            
            if let audio = footprint.audio {
                record["audio"] = CKAsset(fileURL: audio)
            }
            
            database.saveRecord(record) { record, error in
                completion(record: record, error: error)
            }
        }
    }
    
    // MARK: - Delete methods
    
    class func deleteFootprint(recordID: CKRecordID, completion: (error: NSError?) -> Void) {
        database.deleteRecordWithID(recordID) { (recordID, error) in
            completion(error: error)
        }
    }
    
    class func deleteAllFootprints(completion: (error: NSError?) -> Void) {
        var recordIDs = [CKRecordID]()
        
        for footprint in allFootprints {
            recordIDs.append(footprint.recordID)
        }
        
        let operation = CKModifyRecordsOperation()
        operation.recordIDsToDelete = recordIDs
        operation.modifyRecordsCompletionBlock = { (savedRecordIDs, deletedRecordIDs, error) in
            completion(error: error)
        }
        
        database.addOperation(operation)
    }
    
}
