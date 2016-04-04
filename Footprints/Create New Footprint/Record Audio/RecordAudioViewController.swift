//
//  RecordAudioViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 11/16/15.
//  Copyright © 2015 Jorge Tapia. All rights reserved.
//

import UIKit
import AVFoundation

class RecordAudioViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var audioSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    var soundToShareFilePath: NSURL!
    
    var timer = NSTimer()
    var timeInSeconds = 0
    
    var delegate: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioSession = AVAudioSession.sharedInstance()
        
        // Setup audio session and recorder
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: [.DuckOthers, .DefaultToSpeaker])
            try audioSession.setActive(true)
            
            do {
                soundToShareFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("audio.m4a")
                
                let settings = [AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatMPEG4AAC), AVSampleRateKey: 16000.0, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: Int(AVAudioQuality.Low.rawValue)]
                
                audioRecorder = try AVAudioRecorder(URL: soundToShareFilePath, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.prepareToRecord()
                
                recordButton.enabled = true
                playPauseButton.enabled = false
                deleteButton.enabled = false
            } catch {
                self.recordButton.enabled = false
                self.playPauseButton.enabled = false
                self.deleteButton.enabled = false
                
                let error = error as NSError
                
                AppError.handleAsAlert("Error", message: error.localizedDescription, presentingViewController: self) { action in
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        } catch {
            let error = error as NSError
            
            AppError.handleAsAlert("Error", message: error.localizedDescription, presentingViewController: self) { action in
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func saveAction(sender: AnyObject) {
        if delegate is CreateFootprintTableViewController {
            (delegate as! CreateFootprintTableViewController).footprint.audio = soundToShareFilePath
        } else if delegate is DetailTableViewController {
            (delegate as! DetailTableViewController).footprint.audio = soundToShareFilePath
        }
        
        if audioRecorder.recording {
            audioRecorder.stop()
        }
        
        if audioPlayer != nil {
            if audioPlayer.playing {
                audioPlayer.stop()
            }
        }
        
        do {
            try audioSession.setActive(false)
            
            audioSession = nil
            audioPlayer = nil
            audioRecorder = nil
        } catch {
            let error = error as NSError
            NSLog("\(error), \(error.userInfo)")
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func recordAction(sender: AnyObject) {
        if audioRecorder.recording {
            audioRecorder.stop()
        } else {
            audioSession.requestRecordPermission { granted in
                if granted {
                    if let audioPlayer = self.audioPlayer {
                        if audioPlayer.playing {
                            audioPlayer.stop()
                        }
                    }
                    
                    self.audioRecorder.record()
                    
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(RecordAudioViewController.handleTimer), userInfo: nil, repeats: true)
                    
                    self.playPauseButton.enabled = false
                    self.playPauseButton.setImage(UIImage(named: "play"), forState: .Normal)
                    
                    self.deleteButton.enabled = false
                    self.saveButton.enabled = false
                } else {
                    let alert = UIAlertController(title: "Microphone Access", message: "Footprints needs to access your microphone to record audio notes. Please allow microphone access in the Setting app.", preferredStyle: .Alert)
                    
                    let settingsAction = UIAlertAction(title: "Settings", style: .Cancel) { (action) -> Void in
                        let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
                        
                        if UIApplication.sharedApplication().canOpenURL(settingsURL!) {
                            UIApplication.sharedApplication().openURL(settingsURL!)
                        }
                    }
                    
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                    
                    alert.addAction(settingsAction)
                    alert.addAction(dismissAction)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func playPauseAction(sender: AnyObject) {
        if audioPlayer.playing {
            audioPlayer.pause()
            playPauseButton.setImage(UIImage(named: "play"), forState: .Normal)
        } else {
            audioPlayer.play()
            playPauseButton.setImage(UIImage(named: "pause"), forState: .Normal)
        }
    }
    
    @IBAction func deleteAction(sender: AnyObject) {
        if audioPlayer != nil {
            audioPlayer.stop()
        }
        
        playPauseButton.setImage(UIImage(named: "play"), forState: .Normal)
        playPauseButton.enabled = false
        
        deleteButton.enabled = false
        saveButton.enabled = false
        
        timeInSeconds = 0
        timeLabel.text = "00:00"
        
        soundToShareFilePath = nil
    }
    
    // MARK: - Timer handler
    
    func handleTimer() {
        timeInSeconds += 1
        
        timeLabel.text = AppUtils.formatTimeInSeconds(timeInSeconds)
        
        // Stop recording after 30 seconds
        if timeInSeconds == 30 {
            audioRecorder.stop()
        }
    }
    
}

// MARK: - Audio recorder delegate

extension RecordAudioViewController: AVAudioRecorderDelegate {

    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if timer.valid {
            timeInSeconds = 0
            timer.invalidate()
            timer = NSTimer()
        }
        
        do {
            if soundToShareFilePath == nil {
                soundToShareFilePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("audio.m4a")
            }
            
            let fileData = try NSData(contentsOfURL: soundToShareFilePath, options: .MappedRead)
            
            audioPlayer = try AVAudioPlayer(data: fileData)
            audioPlayer.delegate = self
            
            playPauseButton.enabled = true
            deleteButton.enabled = true
            saveButton.enabled = true
        } catch {
            playPauseButton.enabled = false
            deleteButton.enabled = false
            saveButton.enabled = false
            
            let error = error as NSError
            AppError.handleAsAlert("Error", message: error.localizedDescription, presentingViewController: self, completion: nil)
        }
    }
    
}

// MARK: - Audio player delegate

extension RecordAudioViewController: AVAudioPlayerDelegate {

    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        do {
            try audioSession.setActive(false)
        } catch {
            let error = error as NSError
            NSLog("\(error), \(error.userInfo)")
        }
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer, withFlags flags: Int) {
        if flags == AVAudioSessionInterruptionFlags_ShouldResume {
            player.play()
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        player.currentTime = 0.0
        
        playPauseButton.setImage(UIImage(named: "play"), forState: .Normal)
    }
    
}
