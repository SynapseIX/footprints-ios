//
//  AppUtils.swift
//  Footprints
//
//  Created by Jorge Tapia on 10/30/15.
//  Copyright © 2015 Jorge Tapia. All rights reserved.
//

import UIKit
import AVFoundation

class AppUtils {
    
    static let googleApisKey = "AIzaSyDAONSyUyjaCSnnT32aZTQdN1CvPgQwUo0"
    static let appStoreURL = NSURL(string: "https://itunes.apple.com/us/app/id1058674366?ls=1&mt=8")!

    class func imageWithFillColor(color: UIColor, rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColor(context, CGColorGetComponents(color.CGColor))
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    class func formattedStringFromDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE MMMM d, yyyy"
        
        return dateFormatter.stringFromDate(date)
    }
    
    class func twitterfyString(string: String) -> String {
        if string.characters.count > 90 {
            return "\(string.substringToIndex(string.startIndex.advancedBy(86)))..."
        } else {
            return string
        }
    }
    
    class func thumbnailImageForVideo(fileURL: NSURL) -> UIImage? {
        let videoAsset = AVAsset(URL: fileURL)
        
        let imageGenerator = AVAssetImageGenerator(asset: videoAsset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeProductionAperture
        
        var image: UIImage?
        
        do {
            image = try UIImage(CGImage: imageGenerator.copyCGImageAtTime(CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil))
            
            let refWidth = CGImageGetWidth(image?.CGImage)
            let refHeight = CGImageGetHeight(image?.CGImage)
            
            let x = (refWidth - 640) / 2
            let y = (refHeight - 640) / 2
            
            let cropRect = CGRect(x: CGFloat(x), y: CGFloat(y), width: 640.0, height: 640.0)
            let imageRef = CGImageCreateWithImageInRect(image?.CGImage, cropRect)
            
            image = UIImage(CGImage: imageRef!)
        } catch {
            let error = error as NSError
            NSLog("\(error), \(error.userInfo)")
        }
        
        return image
    }
    
    class func formatTimeInSeconds(time: Int) -> String {
        let totalTime = abs(time)
        
        var secondsString = String()
        var minutesString = String()
        
        var seconds = totalTime % 60
        let minutes = totalTime / 60
        
        if seconds > 59 {
            seconds = seconds - (seconds * 60)
        }
        
        // Format seconds
        if 0...9 ~= seconds {
            secondsString = "0\(seconds)"
        } else if 10...59 ~= seconds {
            secondsString = String(seconds)
        }
        
        // Format minutes
        if 0...9 ~= minutes {
            minutesString = "0\(minutes)"
        } else {
            minutesString = String(minutes)
        }
        
        return "\(minutesString):\(secondsString)"
    }
    
    class func deleteFile(fileURL: NSURL?) {
        let fileManager = NSFileManager.defaultManager()
        
        if let fileToDelete = fileURL {
            let path = fileToDelete.absoluteString
            
            if fileManager.fileExistsAtPath(path) {
                do {
                    try fileManager.removeItemAtPath(path)
                } catch {
                    let error = error as NSError
                    AppError.handleAsLog(error.localizedDescription)
                }
            }
        }
    }
    
}
