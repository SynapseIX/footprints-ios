//
//  AppDelegate.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/24/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        AppTheme.apply()
        GMSServices.provideAPIKey(AppUtils.googleApisKey)
        
        if let shortcutItem =
            launchOptions?[UIApplicationLaunchOptionsShortcutItemKey]
                as? UIApplicationShortcutItem {
            handleQuickAction(shortcutItem)
            
            return false
        }
        
        return true
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }
    
    // MARK: - Quick action handler
    
    private func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        let shortcutType = shortcutItem.type
        
        guard let shortcutIdentifier = ShortcutIdentifier(fullIdentifier: shortcutType) else {
            return false
        }
        
        if shortcutIdentifier == .CreateNew {
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if defaults.boolForKey("permissionsSetup") {
                defaults.setBool(true, forKey: "launchCreateNew")
                defaults.synchronize()
                
                return true
            }
        }
        
        return false
    }

}

