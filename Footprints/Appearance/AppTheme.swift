//
//  AppTheme.swift
//  Footprints
//
//  Created by Jorge Tapia on 3/24/16.
//  Copyright © 2016 Jorge Tapia. All rights reserved.
//

import UIKit

class AppTheme {
    
    static let darkGrayColor = UIColor(red: 28.0 / 255.0, green: 28.0 / 255.0, blue: 28.0 / 255.0, alpha: 1.0)
    static let lightPinkColor = UIColor(red: 239.0 / 255.0, green: 68.0 / 255.0, blue: 129.0 / 255.0, alpha: 1.0)
    static let disabledColor = UIColor(red: 66.0 / 255.0, green: 66.0 / 255.0, blue: 66.0 / 255.0, alpha: 1.0)
    static let tableVieCellSelectionColor = UIColor(red: 102.0 / 255.0, green: 102.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0)
    
    static let headingFont = UIFont(name: "DINCondensed-Bold", size: 22.0)
    static let defaultFont = UIFont(name: "AvenirNext-Regular", size: 17.0)
    static let defaultMediumFont = UIFont(name: "AvenirNext-Medium", size: 17.0)
    static let defaultBoldFont = UIFont(name: "AvenirNext-Bold", size: 17.0)
    
    class func apply() {
        // Customizes navigation bars
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barTintColor = lightPinkColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: headingFont ?? UIFont.boldSystemFontOfSize(20.0)]
        
        // Customizes bar button items
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: defaultFont ?? UIFont.systemFontOfSize(17.0)], forState: .Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: disabledColor], forState: .Disabled)
        
        // Customizes tab bars
        UITabBar.appearance().translucent = false
        UITabBar.appearance().barTintColor = darkGrayColor
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        
        let tabBarItemRect = CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width / 5.0, height: 49.0)
        UITabBar.appearance().selectionIndicatorImage = AppUtils.imageWithFillColor(UIColor.blackColor(), rect: tabBarItemRect)
        
        // Customizes labels
        UILabel.appearance().font = defaultFont
        UILabel.appearanceWhenContainedInInstancesOfClasses([UITextField.self]).font = defaultFont?.fontWithSize(14.0)
        
        // Customizes text fields
        UITextField.appearance().font = defaultFont?.fontWithSize(14.0)
        UITextField.appearance().keyboardAppearance = .Dark
        
        // Customizes buttons
        UIButton.appearance().setTitleColor(lightPinkColor, forState: .Normal)
        UIButton.appearance().setTitleColor(disabledColor, forState: .Disabled)
        
        // Customizes text views
        UITextView.appearance().font = defaultFont
        
        // Customizes search bars
        UISearchBar.appearance().barTintColor = lightPinkColor
        UISearchBar.appearance().barStyle = .Black
        UISearchBar.appearance().translucent = false
        UISearchBar.appearance().keyboardAppearance = .Dark
        
        UIDatePicker.appearance().tintColor = lightPinkColor
    }
    
}
