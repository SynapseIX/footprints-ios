//
//  TextNoteViewController.swift
//  Footprints
//
//  Created by Jorge Tapia on 11/9/15.
//  Copyright © 2015 Jorge Tapia. All rights reserved.
//

import UIKit

class TextNoteViewController: UIViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    
    weak var delegate: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if delegate is CreateFootprintTableViewController  {
            textView.text = (delegate as? CreateFootprintTableViewController)?.footprint.notes
        } else if delegate is DetailTableViewController {
            textView.text = (delegate as? DetailTableViewController)?.footprint.notes
        }
        
        textView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addAction(sender: AnyObject) {
        if delegate is CreateFootprintTableViewController {
            (delegate as? CreateFootprintTableViewController)?.footprint.notes = textView.text.characters.count > 0 ? textView.text : nil
        } else if delegate is DetailTableViewController {
            (delegate as? DetailTableViewController)?.footprint.notes = textView.text.characters.count > 0 ? textView.text : nil
        }
        
        navigationController?.popViewControllerAnimated(true)
    }

}
