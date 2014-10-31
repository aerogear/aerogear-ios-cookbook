//
//  ViewController.swift
//  AeroGearSyncDemo
//
//  Created by Daniel Bevenius on 29/10/14.
//  Copyright (c) 2014 Daniel Bevenius. All rights reserved.
//

import UIKit
import AeroGearSyncClient
import AeroGearSync

class ViewController: UIViewController, UITextFieldDelegate {

    let backgroundQueue = NSOperationQueue()

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profession: UITextField!
    @IBOutlet var hobby1: UITextField!
    @IBOutlet var hobby2: UITextField!
    @IBOutlet var hobby3: UITextField!
    @IBOutlet var hobby4: UITextField!
    @IBOutlet var connection: UIButton!
    var dirty = false

    let clientId = NSUUID().UUIDString
    let documentId = "12345"
    var content = Info(name: "Luke Skywalker",
        profession: "Jedi",
        hobbies: ["Fighting the Dark Side",
        "Going into Tosche Station to pick up some power converters",
        "Kissing his sister",
        "Bulls eyeing Womprats on his T-16"])

    var syncClient: SyncClient<DiffMatchPatchSynchronizer, InMemoryDataStore<String>>!

    override func viewDidLoad() {
        super.viewDidLoad()
        profession.delegate = self
        hobby1.delegate = self
        hobby2.delegate = self
        hobby3.delegate = self
        hobby4.delegate = self
        updateFields(content)

        let syncServerHost = NSBundle.mainBundle().objectForInfoDictionaryKey("SyncServerHost")! as String
        let syncServerPort = NSBundle.mainBundle().objectForInfoDictionaryKey("SyncServerPort")! as Int
        let engine = ClientSyncEngine(synchronizer: DiffMatchPatchSynchronizer(), dataStore: InMemoryDataStore())
        syncClient = SyncClient(url: "ws://\(syncServerHost):\(syncServerPort)", syncEngine: engine)
        syncClient.connect()
        let doc = ClientDocument<String>(id: documentId, clientId: clientId, content: content.asJson())
        syncClient.addDocument(doc, callback: syncCallback)
    }

    private func syncCallback(doc: ClientDocument<String>) {
        println("syncCallback: \(doc.content)")
    }

    @IBAction func connection(button: UIButton) {
        let text = button.titleLabel!.text!
        println("Text: \(text)")
        if text == "Disconnect" {
            disconnect()
            connection.setTitle("Connect", forState:UIControlState.Normal)
        } else {
            syncClient.connect()
            connection.setTitle("Disconnect", forState:UIControlState.Normal)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        disconnect()
    }

    func disconnect() {
        syncClient.disconnect()
    }

    private func updateFields(content: Info) {
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.nameLabel.text = content.name
            self.profession.text = content.profession
            self.hobby1.text = content.hobbies[0]
            self.hobby2.text = content.hobbies[1]
            self.hobby3.text = content.hobbies[2]
            self.hobby4.text = content.hobbies[3]
        }
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

