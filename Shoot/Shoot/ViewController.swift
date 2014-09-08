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
import MobileCoreServices
import AssetsLibrary

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
UIActionSheetDelegate, UIAlertViewDelegate {

    var newMedia: Bool = true
    var google: OAuth2Module
    var facebook: OAuth2Module
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        let googleConfig = Config(base: "https://accounts.google.com",
            authzEndpoint: "o/oauth2/auth",
            redirectURL: "org.aerogear.Shoot:/oauth2Callback",
            accessTokenEndpoint: "o/oauth2/token",
            clientId: "873670803862-g6pjsgt64gvp7r25edgf4154e8sld5nq.apps.googleusercontent.com",
            revokeTokenEndpoint: "rest/revoke",
            scopes:["https://www.googleapis.com/auth/drive"],
            accountId: "my_google_account")
        self.google = OAuth2Module(config: googleConfig)
        
        let facebookConfig = Config(base: "",
            authzEndpoint: "https://www.facebook.com/dialog/oauth",
            redirectURL: "fbYYY://authorize/",
            accessTokenEndpoint: "https://graph.facebook.com/oauth/access_token",
            clientId: "YYY",
            clientSecret: "XXX",
            revokeTokenEndpoint: "https://www.facebook.com/me/permissions",
            scopes:["photo_upload, publish_actions"],
            accountId: "my_facebook_account")
        self.facebook = FacebookOAuth2Module(config: facebookConfig)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK - Toolbar Actions
    
    @IBAction func useCamera(sender: UIBarButtonItem) {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            imagePicker.mediaTypes = NSArray(object: kUTTypeImage)
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated:true, completion:{})
            newMedia = true
        }
        
    }
    
    @IBAction func useCameraRoll(sender: UIBarButtonItem) {
        if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self;
            imagePicker.sourceType = .PhotoLibrary
            imagePicker.mediaTypes = NSArray(object: kUTTypeImage)
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated:true, completion:{})
            newMedia = false
        }
    }
    
    @IBAction func share(sender: UIBarButtonItem) {
        let filename = self.imageView.accessibilityIdentifier;
        if (filename == nil) { // nothing was selected
            let alertController = UIAlertController(title: "Error", message: "Please select an image first!", preferredStyle: .Alert)
            presentViewController(alertController, animated: true, completion: nil)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            })
            alertController.addAction(ok)
            return;
        }
        
        let alertController = UIAlertController(title: "Share with", message: nil, preferredStyle: .ActionSheet)
        presentViewController(alertController, animated: true, completion: nil)
        let google = UIAlertAction(title: "Google", style: .Default, handler: { (action) -> Void in
            self.shareWithGoogleDrive()
        })
        alertController.addAction(google)
        let facebook = UIAlertAction(title: "Facebook", style: .Default, handler: { (action) -> Void in
            self.self.shareWithFacebook()
        })
        alertController.addAction(facebook)
        
    }
    
    func shareWithFacebook() {
        println("Perform photo upload with Facebook")
        
        facebook.requestAccessSuccess({(object: AnyObject?)->() in
            println("Facebook Success in OAuth2 grant")
            let http = self.google.http
            
            // TODO AGIOS-229 upload
            http.baseURL = NSURL(string: "https://graph.facebook.com/me/photos")
            self.performUpload(http)
            }, failure: { (error: NSError) -> () in
                println("Facebook Error in OAuth2 grant")
        })
    }
    
    func shareWithGoogleDrive() {
        println("Perform photo upload with Google")

        google.requestAccessSuccess({(object: AnyObject?)->() in
            println("Google Success in OAuth2 grant")
            let http = self.google.http
            
            // TODO AGIOS-229 upload
            http.baseURL = NSURL(string: "https://www.googleapis.com/upload/drive/v2/files")
            self.performUpload(http)
            
            // TODO to be removed onde upload works
            // GET with authz token working ok
            http.baseURL = NSURL(string: "https://www.googleapis.com/drive/v2/files")
            http.GET(success: { (object: AnyObject?) -> Void in
                if let mine: AnyObject = object {
                    println("Success using http GET")
                }
                
            }) { (error: NSError) -> Void in
                    println("Error getting files")
            }
            
        }, failure: { (error: NSError) -> () in
            println("Google Error in OAuth2 grant")
        })
    }

    func performUpload(http: Http) {
        // extract the image filename
        let filename = self.imageView.accessibilityIdentifier;
    
        // Get currently displayed image
        let imageData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
        
        // TODO as part of AGIOS-229
        http.multiPartUpload(http.baseURL!, parameters: ["mypersonal": imageData], success: {(response: AnyObject?) -> Void in
            if (response != nil) {
                println("Successful upload: " + response!.description)
            }
        }
        , failure: {(error: NSError) -> Void in
            println("Failed upload \(error)")
        })
    }
    
    // MARK - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion:nil)
        var image: UIImage = info[UIImagePickerControllerOriginalImage] as UIImage
        if (newMedia == true) {
            UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
        } else {
            var imageURL:NSURL = info[UIImagePickerControllerReferenceURL] as NSURL
            var assetslibrary = ALAssetsLibrary()
            assetslibrary.assetForURL(imageURL, resultBlock: {
                (asset: ALAsset!) in
                if asset != nil {
                    var assetRep: ALAssetRepresentation = asset.defaultRepresentation()
                    self.imageView.accessibilityIdentifier = assetRep.filename()
                    self.imageView.image = image;
                }
            }, failureBlock: {
                (error: NSError!) in
                println("Error \(error)")
            }
            )
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo:UnsafePointer<Void>) {
        self.imageView.image = image;
        self.imageView.accessibilityIdentifier = "Untitled.jpg";
        if let error = didFinishSavingWithError {
            let alert = UIAlertView(title: "Save failed", message: "Failed to save image", delegate: nil, cancelButtonTitle:"OK", otherButtonTitles:"")
                alert.show()
        }
   }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }

}

