//
//  Footprint.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/24/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import CloudKit

class Footprint {
    
    var recordID: CKRecordID!
    var title: String!
    var notes: String?
    var placeName: String?
    var location: CLLocation?
    var date: NSDate!
    var picture: NSURL?
    var audio: NSURL?
    var favorite: Int = 0
    
}
