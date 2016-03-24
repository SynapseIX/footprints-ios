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
}
