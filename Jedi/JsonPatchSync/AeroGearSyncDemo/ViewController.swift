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
import AeroGearSyncClientJsonPatch
import AeroGearSyncJsonPatch

class ViewController: UIViewController, UITextFieldDelegate {

    let backgroundQueue = OperationQueue()

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profession: UITextField!
    @IBOutlet var hobby1: UITextField!
    @IBOutlet var hobby2: UITextField!
    @IBOutlet var hobby3: UITextField!
    @IBOutlet var hobby4: UITextField!
    @IBOutlet var connection: UIButton!
    var dirty = false

    let clientId = UUID().uuidString
    let documentId = "12345"
    var content = Info(name: "Luke Skywalker",
        profession: "Jedi",
        hobbies: [
            Info.Hobby(desc: "Fighting the Dark Side"),
            Info.Hobby(desc: "Going into Tosche Station to pick up some power converters"),
            Info.Hobby(desc: "Kissing his sister"),
            Info.Hobby(desc: "Bulls eyeing Womprats on his T-16")
        ])

    fileprivate var syncClient: SyncClient<JsonPatchSynchronizer, InMemoryDataStore<JsonNode, JsonPatchEdit>>!

    override func viewDidLoad() {
        super.viewDidLoad()
        profession.delegate = self
        hobby1.delegate = self
        hobby2.delegate = self
        hobby3.delegate = self
        hobby4.delegate = self
        updateFields(content)

        let syncServerHost = Bundle.main.object(forInfoDictionaryKey: "SyncServerHost")! as! String
        let syncServerPort = Bundle.main.object(forInfoDictionaryKey: "SyncServerPort")! as! Int
        let syncPath = Bundle.main.object(forInfoDictionaryKey: "SyncServerPath")! as! String
        let engine = ClientSyncEngine(synchronizer: JsonPatchSynchronizer(), dataStore: InMemoryDataStore())
        syncClient = SyncClient(url: "ws://\(syncServerHost):\(syncServerPort)\(syncPath)", syncEngine: engine)
        connect()
        print("ClientId=\(clientId)")
    }

    fileprivate func syncCallback(_ doc: ClientDocument<JsonNode>) {
        updateFieldsMainQueue(Info(dict:doc.content))
    }

    @IBAction func connection(_ button: UIButton) {
        let text = button.titleLabel!.text!
        if text == "Disconnect" {
            disconnect()
            connection.setTitle("Connect", for:UIControlState())
        } else {
            connect()
            connection.setTitle("Disconnect", for:UIControlState())
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        disconnect()
    }

    fileprivate func connect() {
        _ = syncClient.connect()
        syncClient.addDocument(doc: ClientDocument<JsonNode>(id: documentId, clientId: clientId, content: fieldsAsJson()), callback: syncCallback)
    }

    fileprivate func disconnect() {
        syncClient.disconnect()
    }

    fileprivate func updateFieldsMainQueue(_ content: Info) {
        OperationQueue.main.addOperation() {
            self.updateFields(content)
            self.content = content;
        }
    }

    fileprivate func updateFields(_ content: Info) {
        self.nameLabel.text = content.name
        self.profession.text = content.profession
        self.hobby1.text = content.hobbies[0].desc
        self.hobby2.text = content.hobbies[1].desc
        self.hobby3.text = content.hobbies[2].desc
        self.hobby4.text = content.hobbies[3].desc
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /**
    Should the textField in question give up focus.

    :param: textField the UITextField that is in focus
    :returns: Bool true so that the current field gives up focus
    */
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }

    /**
    Hides the keyboard after return button has been pressed.
    This function will also perform a sync if the field in question
    was updated.

    :param: textField the UITextField that is in focus
    :returns: Bool true so that the keyboard is removed.
    */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sync(textField)
        textField.resignFirstResponder()
        return true
    }

    /**
    Called when focus moves from one textfield to another.
    This function will also perform a sync if the field in question
    was updated.

    :param: textField the UITextField that is in focus
    */
    @IBAction func editEnd(_ textField: UITextField) {
        sync(textField)
    }

    /**
    Detects when a field is being updated and takes note of this fact.
    This is later used to determine if a sync should be done or not.
    
    :param: textField the UITextField that is in focus
    */
    @IBAction func updates(_ sender: UITextField) {
        if !dirty {
            dirty = true
        }
    }

    fileprivate func sync(_ field: UITextField) {
        print("syncing...\(String(describing: field.text))")
        let doc = ClientDocument<JsonNode>(id: documentId, clientId: clientId, content: fieldsAsJson())
        if dirty {
            backgroundQueue.addOperation() {
                self.dirty = false
                _ = self.syncClient.diffAndSend(doc)
            }
        }
    }

    fileprivate func fieldsAsJson() -> JsonNode {
        var info = JsonNode()
        
        info["name"] = nameLabel.text! as AnyObject?
        info["profession"] = profession.text! as AnyObject?
        
        info["hobbies"] = [
            ["description" : hobby1.text!],
            ["description" : hobby2.text!],
            ["description" : hobby3.text!],
            ["description" : hobby4.text!]]
        
        return info
    }
}

