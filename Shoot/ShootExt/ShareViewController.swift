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
import Social
import MobileCoreServices
import AeroGearHttp
import AeroGearOAuth2

let ssoKeychainGroup = "357BX7TCT5.org.aerogear.Shoot"
let appGroup = "group.org.aerogear.Shoot"

public class OAuth2ModuleExtension: OAuth2Module {
    // For extension we do not want to be redirected to browser to authenticate
    // As a pre-requisite we should have a valid access_token stored in Keychain
    override public func requestAuthorizationCode(completionHandler: (AnyObject?, NSError?) -> Void) {
        completionHandler("NO_TOKEN", nil)
    }
}

class ShareViewController: SLComposeServiceViewController, UIWebViewDelegate {
    
    var imageToShare: UIImage?
    var accessToken: String?
    var http: Http
    
    required init(coder aDecoder: NSCoder) {
        // create background session
        var sessionConf = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(appGroup + "backgroundSession" + NSUUID().UUIDString)
        sessionConf.sharedContainerIdentifier = appGroup
        self.http = Http(sessionConfig: sessionConf)
        super.init(coder: aDecoder)
    }
    
    override func isContentValid() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        let items = extensionContext?.inputItems
        var itemProvider: NSItemProvider?
        
        if items != nil && items!.isEmpty == false {
            let item = items![0] as NSExtensionItem
            if let attachments = item.attachments {
                if !attachments.isEmpty {
                    itemProvider = attachments[0] as? NSItemProvider
                }
            }
        }
        
        let imageType = kUTTypeImage as NSString as String
        if itemProvider?.hasItemConformingToTypeIdentifier(imageType) == true {
            
            itemProvider?.loadItemForTypeIdentifier(imageType, options: nil) { item, error in
                    if error == nil {
                        let url = item as NSURL
                        let imageData = NSData(contentsOfURL: url)
                        self.imageToShare = UIImage(data: imageData!)
                    } else {
                        let title = "Unable to load image"
                        let message = "Please try again or choose a different image."
                        
                        let alert = UIAlertController(title: title,
                            message: message,
                            preferredStyle: .Alert)
                        
                        let action = UIAlertAction(title: "Bummer", style: .Cancel) { _ in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
            }
        }
    }
    
    override func didSelectPost() {
        println("Perform photo upload with Google")
        
        // We can not use googleconfig as per default it take your ext bundle id, here we wnat to takes shoot app bundle id for redirect_uri
        let googleConfig = Config(base: "https://accounts.google.com",
                authzEndpoint: "o/oauth2/auth",
                redirectURL: "org.aerogear.Shoot:/oauth2Callback",
                accessTokenEndpoint: "o/oauth2/token",
                clientId: "873670803862-g6pjsgt64gvp7r25edgf4154e8sld5nq.apps.googleusercontent.com",
                refreshTokenEndpoint: "o/oauth2/token",
                revokeTokenEndpoint: "rest/revoke",
                scopes:["https://www.googleapis.com/auth/drive"])
        
        // Create a TrustedPersistantOAuth2Session with a groupId for keychain group sharing
        let gdModule = OAuth2ModuleExtension(config: googleConfig, session: TrustedPersistantOAuth2Session(accountId: "ACCOUNT_FOR_CLIENTID_\(googleConfig.clientId)", groupId: ssoKeychainGroup))
        
        self.http.authzModule = gdModule
        gdModule.requestAccess { (response: AnyObject?, error: NSError?) -> Void in
            var accessToken = response as? String
            if accessToken == "NO_TOKEN" {
                println("You should go to Shoot app and grant oauth2 access")
            } else {
                println("accessToken \(accessToken)")
               
                let imageURL = self.saveImage(self.imageToShare!, name: NSUUID().UUIDString)
                // multipart upload
                let multiPartData = MultiPartData(url: imageURL!,
                            mimeType: "image/jpg")
                let parameters = ["file": multiPartData]
                /*
                // multi-part upload could be achievd either with upload as a stream or using POST
                self.http.upload("https://www.googleapis.com/upload/drive/v2/files", stream: NSInputStream(URL: imageURL!)!, parameters: parameters, method: .POST, progress: { (ar1:Int64, ar2:Int64, arr3:Int64) -> Void in
                    println("Uploading...")
                    }) { (response: AnyObject?, error: NSError?) -> Void in
                    println("Uploaded: \(response) \(error)")
                }
                */
                self.http.POST("https://www.googleapis.com/upload/drive/v2/files", parameters: parameters, completionHandler: {(response, error) in
                    if (error != nil) {
                        println("Error: \(error!.localizedDescription)")
                    } else {
                        println("Successfully uploaded!")
                    }
                })
            }
            
        }
 


        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequestReturningItems([], completionHandler: {(Bool) -> Void in
            println("completion ...")
        })
    }
    
    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    // Mark - Utilities methods
    
    // For background processing we should save the image to be uploaded later
    private func saveImage(image: UIImage, name: String) -> NSURL? {
        var imageDirectoryURL = urlForDirectoryWithName("images")
        imageDirectoryURL = imageDirectoryURL.URLByAppendingPathComponent(name)
        imageDirectoryURL = imageDirectoryURL.URLByAppendingPathExtension("jpg")
        // here we do not compress the image, as a result upload will take time and we make sure background processing has time to complete
        let imageData = UIImageJPEGRepresentation(image, 1)
        let saved = imageData.writeToFile(imageDirectoryURL.path!, atomically: true)
        return imageDirectoryURL
    }
    
    private func urlForDirectoryWithName(name: String) -> NSURL! {
        if let containerURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(appGroup) {
            var containerURLWithName = containerURL.URLByAppendingPathComponent(name)
            if !NSFileManager.defaultManager().fileExistsAtPath(containerURLWithName.path!) {
                NSFileManager.defaultManager().createDirectoryAtPath(containerURLWithName.path!, withIntermediateDirectories: false, attributes: nil, error: nil)
            }
            return containerURL
        } else {
            fatalError("Unable to obtain container URL for app group, verify your app group settings.")
            return nil
        }
    }
}
