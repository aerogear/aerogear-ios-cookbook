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
import AeroGearOAuth2

let HOST = "http://localhost:8080"

class ViewController: UIViewController {
    var userInfo: OpenIDClaim?
    var keycloakHttp = Http()
    var images: [UIImage] = []
    var currentIndex = 0
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
    
    @IBAction func goPreviousImage(sender: UIButton) {
        if  self.currentIndex > 0 {
            self.currentIndex--
        }
        self.imageView.image = self.images[self.currentIndex]
    }
    
    @IBAction func goNextImage(sender: UIButton) {
        if  self.currentIndex < self.images.count - 1{
            self.currentIndex++
        }
        self.imageView.image = self.images[self.currentIndex]
    }
    
    @IBAction func loginAsKeycloak(sender: AnyObject) {
        let keycloakConfig = KeycloakConfig(
            clientId: "sharedshoot-third-party",
            host: HOST,
            realm: "shoot-realm",
            isOpenIDConnect: true)
        let oauth2Module = AccountManager.addKeycloakAccount(keycloakConfig)
        self.keycloakHttp.authzModule = oauth2Module
        oauth2Module.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in
            self.userInfo = claims
            if let userInfo = claims {
                if let name = userInfo.name {
                    self.nameLabel.text = "Hello \(name)"
                }
            }
            // Get the list of photos
            self.keycloakHttp.GET("\(HOST)/shoot/rest/photos", parameters: nil, completionHandler: { (response: AnyObject?, error: NSError?) -> Void in
                if error != nil {
                    print("Oops something must have being wrong. Check your URL. Is your Keycloak server running? \n\(error)")
                }
                let files = response as! [AnyObject]
                let _ = files.map({ (file: AnyObject) -> () in
                    let image = file as? [String: AnyObject]
                    if let image = image {
                        let fileId = image["filename"] as! String
                        // Find the path where the photo will be downloaded
                        let fileManager = NSFileManager.defaultManager()
                        let path  = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
                        try! fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
                        let finalDestination = (path as NSString).stringByAppendingPathComponent(fileId)
                        // Download the photo one by one
                        self.keycloakHttp.download("\(HOST)/shoot/rest/photos/images/\(fileId)",
                            progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)  in

                            }, completionHandler: { (response, error) in
                                let fileBase64EncodedContent: NSString? = try! NSString(contentsOfFile: finalDestination, encoding: NSUTF8StringEncoding)
                                if let fileBase64EncodedContent = fileBase64EncodedContent {
                                    let data:NSData? = NSData(base64EncodedString: fileBase64EncodedContent as String, options: NSDataBase64DecodingOptions(rawValue: 0))
                                    if let data = data {
                                        if let image = UIImage(data: data) {
                                            self.images.append(image)
                                        }
                                    }
                                }
                                // Sucessfull login, all photo downloaded let's display first one
                                if  self.images.count > 0 && self.imageView.image == nil {
                                    self.imageView.image = self.images[self.currentIndex]
                                }
                        })
                    }
                })
            })
        }
    }
    
}

