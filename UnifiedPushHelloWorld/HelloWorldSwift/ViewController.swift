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
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.registered), name: Notification.Name(rawValue: "success_registered"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.errorRegistration), name: Notification.Name(rawValue: "error_register"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.messageReceived(_:)), name: Notification.Name(rawValue: "message_received"), object: nil)
    }
   
    func registered() {
        print("registered")
        
        // workaround to get messages when app was not running
        let defaults: UserDefaults = UserDefaults.standard;
        if let obj = defaults.object(forKey: "message_received") {
            defaults.removeObject(forKey: "message_received")
            defaults.synchronize()
    
            if let msg = obj as? String {
                messages.append(msg)
            }
        }
        
        isRegistered = true
        tableView.reloadData()
    }

    func errorRegistration() {
        // can't do much, inform user to verify the UPS details entered and return
        let message = UIAlertController(title: "Registration Error!", message: "Please verify the provisionioning profile and the UPS details have been setup correctly.", preferredStyle:  .alert)
        
        self.present(message, animated:true, completion:nil)
    }
    
    func messageReceived(_ notification: Notification) {
        print("received")
        if let userInfo = notification.userInfo, let aps = userInfo["aps"] as? [String: Any] {
            // if alert is a flat string
            if let msg = aps["alert"] as? String {
                messages.append(msg)
            } else if let obj = aps["alert"] as? [String: Any], let msg = obj["body"] as? String {
                // if the alert is a dictionary we need to extract the value of the body key
                messages.append(msg)
            }
        }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var bgView:UIView?
        
        // determine current state
        if (!isRegistered) {  // not yet registered
            let progress = self.navigationController?.storyboard?.instantiateViewController(withIdentifier: "ProgressViewController")
            if let progress = progress {bgView = progress.view}
        } else if (messages.count == 0) {  // registered but no notification received yet
            let empty = self.navigationController?.storyboard?.instantiateViewController(withIdentifier: "EmptyViewController")
            if let empty = empty {bgView = empty.view}
        }
        
        // set the background view if needed
        if (bgView != nil) {
            self.tableView.backgroundView = bgView
            self.tableView.separatorStyle = .none
            return 0
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // if it's the first message in the stream, let's clear the 'empty' placeholder vier
        if (self.tableView.backgroundView != nil) {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: AGNotificationCellIdentifier)!
        cell.textLabel?.text = messages[(indexPath as IndexPath).row]
        
        return cell
    }
}

