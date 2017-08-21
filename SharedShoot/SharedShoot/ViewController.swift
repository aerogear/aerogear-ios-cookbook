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

extension String {
    /// Encode a String to Base64
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    /// Decode a String from Base64. Returns nil if unsuccessful.
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

class ViewController: UIViewController {
    var userInfo: OpenIdClaim?
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
    
    @IBAction func goPreviousImage(_ sender: UIButton) {
        if  self.currentIndex > 0 {
            self.currentIndex -= 1
        }
        self.imageView.image = self.images[self.currentIndex]
    }
    
    @IBAction func goNextImage(_ sender: UIButton) {
        if  self.currentIndex < self.images.count - 1{
            self.currentIndex += 1
        }
        self.imageView.image = self.images[self.currentIndex]
    }
    

    
    @IBAction func loginAsKeycloak(_ sender: AnyObject) {
        let keycloakConfig = KeycloakConfig(
            clientId: "sharedshoot-third-party",
            host: HOST,
            realm: "shoot-realm",
            isOpenIDConnect: true)
        let oauth2Module = AccountManager.addKeycloakAccount(config: keycloakConfig)
        self.keycloakHttp.authzModule = oauth2Module
        oauth2Module.login {(accessToken: AnyObject?, claims: OpenIdClaim?, error: NSError?) in
            self.userInfo = claims
            if let userInfo = claims {
                if let name = userInfo.name {
                    self.nameLabel.text = "Hello \(name)"
                }
            }
            // Get the list of photos
            self.keycloakHttp.request(method: .get, path: "\(HOST)/shoot/rest/photos", parameters: nil, completionHandler: { (response: Any?, error: NSError?) -> Void in
                if error != nil {
                    print("Oops something must have being wrong. Check your URL. Is your Keycloak server running? \n\(error)")
                } else {
                    let files = response as! [AnyObject]
                    let _ = files.map({ (file: AnyObject) -> () in
                        let image = file as? [String: AnyObject]
                        if let image = image {
                            let fileId = image["filename"] as! String
                            // Find the path where the photo will be downloaded
                            let fileManager = FileManager.default
                            let path  = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                            let finalDestination = (path as NSString).appendingPathComponent(fileId)
                            // Download the photo one by one
                            self.keycloakHttp.download(url: "\(HOST)/shoot/rest/photos/images/\(fileId)",
                                progress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)  in
                            }, completionHandler: { (response, error) in
                                let fileBase64EncodedContent = try? String(contentsOfFile: finalDestination, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                                if let fileBase64EncodedContent = fileBase64EncodedContent {
                                    let data:NSData? = NSData(base64Encoded: fileBase64EncodedContent, options: NSData.Base64DecodingOptions(rawValue: 0))
                                    if let data = data {
                                        if let image = UIImage(data: data as Data) {
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
                }
            })
        }
    }
    
}

