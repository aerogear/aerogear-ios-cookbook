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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var newMedia: Bool = true
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
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
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) in })
            alertController.addAction(ok)
            return;
        }
        
        let alertController = UIAlertController(title: "Share with", message: nil, preferredStyle: .ActionSheet)
        presentViewController(alertController, animated: true, completion: nil)
        let google = UIAlertAction(title: "Google", style: .Default, handler: { (action) in
            self.shareWithGoogleDrive()
        })
        alertController.addAction(google)
        let facebook = UIAlertAction(title: "Facebook", style: .Default, handler: { (action) in
            self.self.shareWithFacebook()
        })
        alertController.addAction(facebook)
        
    }
    
    func shareWithFacebook() {
        println("Perform photo upload with Facebook")
        let facebookConfig = FacebookConfig(
            clientId: "YYY",
            clientSecret: "XXX",
            scopes:["photo_upload, publish_actions"])
        
        let fbModule =  AccountManager.addFacebookAccount(facebookConfig)
        
        let http = Http(url: "https://graph.facebook.com/me/photos")
        http.authzModule = fbModule
        
        self.performUpload(http)
    }
    
    func shareWithGoogleDrive() {
        println("Perform photo upload with Google")
        let googleConfig = GoogleConfig(
            clientId: "873670803862-g6pjsgt64gvp7r25edgf4154e8sld5nq.apps.googleusercontent.com",
            scopes:["https://www.googleapis.com/auth/drive"])

        let gdModule = AccountManager.addGoogleAccount(googleConfig)
        let http = Http(url: "https://www.googleapis.com/drive/v2/files")
        http.authzModule = gdModule
        
        http.GET(success: { (object: AnyObject?) -> Void in
            if let mine: AnyObject = object {
                println("Success using http GET")
            }
            }, failure: { (error: NSError) -> Void in
                println("Error getting files: \(error)")
        })

        // TODO AGIOS-229 upload
        //http.baseURL = NSURL(string: "https://www.googleapis.com/upload/drive/v2/files")
        //self.performUpload(http)
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

