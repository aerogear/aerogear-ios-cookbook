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

class BaconViewController: UITableViewController {

    var data = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let credential = URLCredential(user: "agnes", password: "123", persistence: .none)
        Network.http.request(method: .get, path:"/rest/grocery/bacons",  credential: credential,
            completionHandler: { (response: Any?, error: NSError?) -> Void in
                if error != nil {
                    print("An error has occured during read! \(error!)")
                    return
                }
                
                // set data and refresh
                self.data = response as! [String]
                self.tableView.reloadData()
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
}

