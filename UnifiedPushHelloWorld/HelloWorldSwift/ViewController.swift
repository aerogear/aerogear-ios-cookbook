/*
* JBoss, Home of Professional Open Source.
* Copyright Red Hat, Inc., and individual contributors
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit

class ViewController: UITableViewController {
                            
    let AGNotificationCellIdentifier = "AGNotificationCell"
    var isRegistered = false
    
    // holds the messages received and displayed on tableview
    var messages: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register to be notified when state changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.registered), name: "success_registered", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.errorRegistration), name: "error_register", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.messageReceived(_:)), name: "message_received", object: nil)
    }
   
    func registered() {
        print("registered")
        
        // workaround to get messages when app was not running
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults();
        if(defaults.objectForKey("message_received") != nil) {
            let msg : String! = defaults.objectForKey("message_received") as! String
            defaults.removeObjectForKey("message_received")
            defaults.synchronize()
    
            if(msg != nil) {
                messages.append(msg)
            }
        }
        
        isRegistered = true
        tableView.reloadData()
    }

    func errorRegistration() {
        // can't do much, inform user to verify the UPS details entered and return
        let message = UIAlertController(title: "Registration Error!", message: "Please verify the provisionioning profile and the UPS details have been setup correctly.", preferredStyle:  .Alert)
        
        self.presentViewController(message, animated:true, completion:nil)
    }
    
    func messageReceived(notification: NSNotification) {
        print("received")

        let obj:AnyObject? = notification.userInfo!["aps"]!["alert"]
        
        // if alert is a flat string
        if let msg = obj as? String {
            messages.append(msg)
        } else {
            // if the alert is a dictionary we need to extract the value of the body key
            let msg = obj!["body"] as! String
            messages.append(msg)
        }
        
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var bgView:UIView?
        
        // determine current state
        if (!isRegistered) {  // not yet registered
            let progress = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("ProgressViewController")
            if let progress = progress {bgView = progress.view}
        } else if (messages.count == 0) {  // registered but no notification received yet
            let empty = self.navigationController?.storyboard?.instantiateViewControllerWithIdentifier("EmptyViewController")
            if let empty = empty {bgView = empty.view}
        }
        
        // set the background view if needed
        if (bgView != nil) {
            self.tableView.backgroundView = bgView
            self.tableView.separatorStyle = .None
            return 0
        }
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // if it's the first message in the stream, let's clear the 'empty' placeholder vier
        if (self.tableView.backgroundView != nil) {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .SingleLine
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(AGNotificationCellIdentifier)!
        cell.textLabel?.text = messages[indexPath.row]
        
        return cell
    }
}

