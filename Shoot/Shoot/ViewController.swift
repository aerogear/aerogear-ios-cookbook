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
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            let alert = UIAlertView(title: "Error", message: "Please select an image first!", delegate: nil, cancelButtonTitle:"OK",            otherButtonTitles:"")
            alert.show()
            return;
        }
        let actionSheet = UIActionSheet(title:nil, delegate:self, cancelButtonTitle:"Cancel", destructiveButtonTitle:nil, otherButtonTitles:"Facebook", "Google")
        actionSheet.showInView(self.view)
    }
    
    
    // MARK - ActionSheet Actions
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex:NSInteger) {
        if (actionSheet.buttonTitleAtIndex(clickedButtonAtIndex) == "Facebook") {
            self.shareWithFacebook()
        } else if(actionSheet.buttonTitleAtIndex(clickedButtonAtIndex) == "Google") {
            self.shareWithGoogleDrive()
        }
    }
    
    func shareWithFacebook() {
        println("Perform photo upload with Facebook")
        performUpload()
    }
    
    func shareWithGoogleDrive() {
        println("Perform photo upload with Google")
        
        let googleConfig = Config(base: "https://accounts.google.com",
                                    authzEndpoint: "o/oauth2/auth",
                                    redirectURL: "org.aerogear.Shoot:/oauth2Callback",
                                    accessTokenEndpoint: "o/oauth2/token",
                                    clientId: "873670803862-g6pjsgt64gvp7r25edgf4154e8sld5nq.apps.googleusercontent.com",
                                    revokeTokenEndpoint: "rest/revoke",
                                    scopes:["https://www.googleapis.com/auth/drive"],
                                    accountId: "my_google_account")
        
        var oauth2Module = OAuth2Module(config: googleConfig)
        oauth2Module.requestAccessSuccess({(object: AnyObject?)->() in
                println("sucess")
            }, failure: { (error: NSError) -> () in
                println("error")
        })

        performUpload()
    }

    func performUpload() {
        // extract the image filename
        let filename = self.imageView.accessibilityIdentifier;
    
        // Get currently displayed image
        let imageData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
    
        // set up payload with the image
        //TODO
   
        // upload file
        // TODO
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
                println("Error\(error)")
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

