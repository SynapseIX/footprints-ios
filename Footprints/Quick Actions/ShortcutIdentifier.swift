//
//  ShortcutIdentifier.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/27/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import Foundation

enum ShortcutIdentifier: String {

    case CreateNew
    
    init?(fullIdentifier: String) {
        guard let shortIdentifier = fullIdentifier.componentsSeparatedByString(".").last else {
            return nil
        }
        
        self.init(rawValue: shortIdentifier)
    }
    
}