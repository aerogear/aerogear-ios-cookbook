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

class ViewController: UIViewController {
    var userInfo: OpenIDClaim?
    var keycloakHttp = Http()
    var images: [UIImage] = []
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "seeImages:" {
        
        self.keycloakHttp.GET("http://localhost:8080/shoot/photos", parameters: nil, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
                if error != nil {
                    println("ERROR::\(error)")
                }
                println("Get list of photos::\(response)")
            })
        }
    }
    
    @IBAction func loginAsKeycloak(sender: AnyObject) {
        let keycloakConfig = KeycloakConfig(
            clientId: "sharedshoot-third-party",
            host: "http://localhost:8080",
            realm: "shoot-realm",
            isOpenIDConnect: true)
        var oauth2Module = AccountManager.addKeycloakAccount(keycloakConfig)
        self.keycloakHttp.authzModule = oauth2Module
        oauth2Module.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in
            self.userInfo = claims
            //self.nameLabel.text = "Hello \(claims?.name)"
            
            // Get the list of photos
            self.keycloakHttp.GET("http://localhost:8080/shoot/rest/photos", parameters: nil, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
                if error != nil {
                    println("Oops something must have being wrong. Check your URL. Is your Keycloak server running? \n\(error)")
                }
                var files = response as [AnyObject]
                files.map({ (file: AnyObject) -> () in
                    let image = file as? [String: AnyObject]
                    if let image = image {
                        let fileId = image["filename"] as String
                        // Find the path where the photo will be downloaded
                        let fileManager = NSFileManager.defaultManager()
                        let path  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                        fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
                        let finalDestination = path.stringByAppendingPathComponent(fileId)
                        // Download the photo one by one
                        self.keycloakHttp.download("http://localhost:8080/shoot/rest/photos/images/\(fileId)",
                            progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)  in
                                println("bytesWritten: \(bytesWritten), totalBytesWritten: \(totalBytesWritten), totalBytesExpectedToWrite: \(totalBytesExpectedToWrite)")
                            }, completionHandler: { (response, error) in
                                if let fileBase64EncodedContent =  NSString(contentsOfFile: finalDestination, encoding: NSUTF8StringEncoding, error: nil) {
                                    if let data = NSData(base64EncodedString: fileBase64EncodedContent, options: NSDataBase64DecodingOptions.allZeros) {
                                        if let image = UIImage(data: data) {
                                            self.images.append(image)
                                        }
                                    }
                                }
                                // Sucessfull login, all photo downloaded let's display first one
                                if  self.images.count > 0 && self.imageView.image == nil {
                                    self.imageView.image = self.images[0]
                                }
                        })
                    }
                })
            })
        }
    }
    
}

