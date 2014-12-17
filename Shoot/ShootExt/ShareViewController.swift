//
//  ShareViewController.swift
//  ShootExt
//
//  Created by Corinne Krych on 16/12/14.
//  Copyright (c) 2014 AeroGear. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import AeroGearHttp
import AeroGearOAuth2

// TODO replace the constant by your APP ID
let ssoKeychainGroup = "357BX7TCT5.org.aerogear.Shoot"
let appGroup = "group.org.aerogear.Shoot"

public class OAuth2ModuleExtension: OAuth2Module {
    override public func requestAuthorizationCode(completionHandler: (AnyObject?, NSError?) -> Void) {
        completionHandler("NO_TOKEN", nil)
    }
}

class ShareViewController: SLComposeServiceViewController, UIWebViewDelegate {
    
    var imageToShare: UIImage?
    var accessToken: String?
    var http = Http()
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
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

                // multipart upload
                let multiPartData = MultiPartData(data: UIImageJPEGRepresentation(self.imageToShare, 0.2),
                    name: "image",
                    filename: "filename.jpg",
                    mimeType: "image/jpg")
                let parameters = ["file": multiPartData]
                //var sessionConf = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(appGroup)
                //sessionConf.sharedContainerIdentifier = appGroup
                //var backgroundHttp = Http(sessionConfig: sessionConf)
                //backgroundHttp.authzModule = gdModule
                self.http.POST("https://www.googleapis.com/upload/drive/v2/files", parameters: parameters, completionHandler: {(response, error) in
                    if (error != nil) {
                        println("Error:: \(error!.localizedDescription)")
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
}
