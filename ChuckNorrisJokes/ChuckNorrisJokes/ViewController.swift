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

import AeroGearHttp
import AeroGearJsonSZ

class MasterViewController: UITableViewController {

    var http = Http()
    var data: [Joke] = []
    var serializer = JsonSZ()

    func addRandomJokeToTableView() -> () {
        var _: String
        http.request(.GET, path: "http://api.icndb.com/jokes/random/", completionHandler: { (response, error) -> Void in
             if error != nil {
                print("An error has occured during read! \(error!)")
                return;
            }
            
            if  let obj = response as? [String: AnyObject] {
                    let joke = self.serializer.fromJSON(obj["value"]!, to: Joke.self)
                    self.data.append(joke)
                    self.tableView.reloadData()
            }
        })
    }
    
    override func viewDidLoad() {

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0

        super.viewDidLoad()
        addRandomJokeToTableView()
    }

    @IBAction func add(sender: UIBarButtonItem) {
        addRandomJokeToTableView()
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath) as! BasicCell

        let joke = data[indexPath.row]
        cell.titleLabel.text = "Joke #\(joke.id)"
        cell.subtitleLabel.text = joke.joke
        cell.tag = indexPath.row
        
        return cell
    }
}

class Joke: JSONSerializable {
    var id: Int = 0
    var joke: String = ""
    
    init(id: Int, joke: String) {
        self.id = id
        self.joke = joke
    }
    
    required init() {}
    
    class func map(source: JsonSZ, object: Joke) {
        object.id <= source["id"]
        object.joke <= source["joke"]
    }

}

extension Joke: CustomStringConvertible {
    var description: String {
        get {
            var description = ">>"
            description += "id:\(id) "
            description += "joke:\(joke) "
            return description
        }
    }
}

