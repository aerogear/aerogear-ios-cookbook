//
//  ViewController.swift
//  AeroGearSyncDemo
//
//  Created by Daniel Bevenius on 29/10/14.
//  Copyright (c) 2014 Daniel Bevenius. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profession: UITextField!
    @IBOutlet var hobby1: UITextField!
    @IBOutlet var hobby2: UITextField!
    @IBOutlet var hobby3: UITextField!
    @IBOutlet var hobby4: UITextField!
    var dirty = false
    let backgroundQueue = NSOperationQueue()

    override func viewDidLoad() {
        super.viewDidLoad()
        profession.delegate = self
        hobby1.delegate = self
        hobby2.delegate = self
        hobby3.delegate = self
        hobby4.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /**
    Should the textField in question give up focus.

    :param: textField the UITextField that is in focus
    :returns: Bool true so that the current field gives up focus
    */
    func textFieldShouldEndEditing(textField: UITextField!) -> Bool {
        return true
    }

    /**
    Hides the keyboard after return button has been pressed.
    This function will also perform a sync if the field in question
    was updated.

    :param: textField the UITextField that is in focus
    :returns: Bool true so that the keyboard is removed.
    */
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        sync(textField)
        return true
    }

    /**
    Called when focus moves from one textfield to another.
    This function will also perform a sync if the field in question
    was updated.

    :param: textField the UITextField that is in focus
    */
    @IBAction func editEnd(textField: UITextField) {
        sync(textField)
    }

    /**
    Detects when a field is being updated and takes note of this fact.
    This is later used to determine if a sync should be done or not.
    
    :param: textField the UITextField that is in focus
    */
    @IBAction func updates(sender: UITextField) {
        if !dirty {
            println("field updating...\(sender.text)")
            dirty = true
        }
    }

    private func sync(field: UITextField) {
        if dirty {
            backgroundQueue.addOperationWithBlock() {
                println("syncing...\(field.text)")
                self.dirty = false
            }
        }
    }
}

