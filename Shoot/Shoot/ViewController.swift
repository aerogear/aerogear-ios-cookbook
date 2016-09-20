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

import AeroGearHttp
import AeroGearOAuth2

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var overlayView: UIView?
    var imagePicker = UIImagePickerController()
    var newMedia: Bool = true
    var http: Http!
    @IBOutlet weak var imageView: UIImageView!


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {

        super.viewDidLoad()

        // Let's register for settings update notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.handleSettingsChangedNotification),
            name: NSUserDefaultsDidChangeNotification, object: nil)
        self.http = Http()
        self.useCamera()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    func handleSettingsChangedNotification() {

        let userDefaults = NSUserDefaults.standardUserDefaults()
        let clear = userDefaults.boolForKey("clearShootKeychain")

        if clear {
            print("clearing keychain")
            let kc = KeychainWrap()
            kc.resetKeychain()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func goToCamera(sender: UIButton) {
        self.useCamera()
    }

    @IBAction func takePicture(sender: UIBarButtonItem) {
        self.imagePicker.takePicture()
    }

    @IBAction func goToSettings(sender: AnyObject) {
        let settingsUrl = NSURL(string:UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(settingsUrl!)
    }

    func useCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            imagePicker.mediaTypes = [String(kUTTypeImage)]
            imagePicker.allowsEditing = false
            
            // custom camera overlayview
            imagePicker.showsCameraControls = false
            NSBundle.mainBundle().loadNibNamed("OverlayView", owner:self, options:nil)
            self.overlayView!.frame = imagePicker.cameraOverlayView!.frame
            imagePicker.cameraOverlayView = self.overlayView
            self.overlayView = nil
            self.presentViewController(imagePicker, animated:true, completion:{})
            newMedia = true
        } else {
            if (UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum)) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self;
                imagePicker.sourceType = .PhotoLibrary
                imagePicker.mediaTypes = [String(kUTTypeImage)]
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated:true, completion:{})
                newMedia = false
            }
        }
    }

    @IBAction func shareWithFacebook() {
        print("Perform photo upload with Facebook")
        let facebookConfig = FacebookConfig(
            clientId: "YYY",
            clientSecret: "XXX",
            scopes:["photo_upload, publish_actions"])
        // If you want to use embedded web view uncomment
        //facebookConfig.isWebView = true
        
        // Workaround issue on Keychain https://forums.developer.apple.com/message/23323
        let fbModule = KeycloakOAuth2Module(config: facebookConfig, session: UntrustedMemoryOAuth2Session(accountId: "ACCOUNT_FOR_CLIENTID_\(facebookConfig.clientId)"))
        //let fbModule =  AccountManager.addFacebookAccount(facebookConfig)
        self.http.authzModule = fbModule

        self.performUpload("https://graph.facebook.com/me/photos",  parameters: self.extractImageAsMultipartParams())
    }

    @IBAction func shareWithGoogleDrive() {
        print("Perform photo upload with Google")

        let googleConfig = GoogleConfig(
            clientId: "873670803862-g6pjsgt64gvp7r25edgf4154e8sld5nq.apps.googleusercontent.com",
            scopes:["https://www.googleapis.com/auth/drive"])
        // If you want to use embedded web view uncomment
        //googleConfig.isWebView = true
        
        // Workaround issue on Keychain https://forums.developer.apple.com/message/23323
        let gdModule = KeycloakOAuth2Module(config: googleConfig, session: UntrustedMemoryOAuth2Session(accountId: "ACCOUNT_FOR_CLIENTID_\(googleConfig.clientId)"))
        
        //let gdModule = AccountManager.addGoogleAccount(googleConfig)
        self.http.authzModule = gdModule
        self.performUpload("https://www.googleapis.com/upload/drive/v2/files", parameters: self.extractImageAsMultipartParams())
    }

    @IBAction func shareWithKeycloak() {
        print("Perform photo upload with Keycloak")

        let keycloakHost = "http://localhost:8080"
        let keycloakConfig = KeycloakConfig(
            clientId: "shoot-third-party",
            host: keycloakHost,
            realm: "shoot-realm")
        // If you want to use embedded web view uncomment
        //keycloakConfig.isWebView = true
        
        // Workaround issue on Keychain https://forums.developer.apple.com/message/23323
        let gdModule = KeycloakOAuth2Module(config: keycloakConfig, session: UntrustedMemoryOAuth2Session(accountId: "ACCOUNT_FOR_CLIENTID_\(keycloakConfig.clientId)"))
        //let gdModule = AccountManager.addKeycloakAccount(keycloakConfig)
        self.http.authzModule = gdModule
        self.performUpload("\(keycloakHost)/shoot/rest/photos", parameters: self.extractImageAsMultipartParams())

    }

    func performUpload(url: String, parameters: [String: AnyObject]?) {
        self.http.request(.POST, path: url, parameters: parameters, completionHandler: {(response, error) in
            if (error != nil) {
                self.presentAlert("Error", message: error!.localizedDescription)
            } else {
                self.presentAlert("Success", message: "Successfully uploaded!")
            }
        })
    }

    // MARK - UIImagePickerControllerDelegate

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        self.dismissViewControllerAnimated(true, completion:nil)
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        if (newMedia == true) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            let imageURL:NSURL = info[UIImagePickerControllerReferenceURL] as! NSURL
            let assetslibrary = ALAssetsLibrary()
            assetslibrary.assetForURL(imageURL, resultBlock: {
                (asset: ALAsset!) in
                if asset != nil {
                    let assetRep: ALAssetRepresentation = asset.defaultRepresentation()
                    self.imageView.accessibilityIdentifier = assetRep.filename()
                    self.imageView.image = image;
                }
            }, failureBlock: {
                (error: NSError!) in
                print("Error \(error)")
            }
            )
        }
    }

    func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo:UnsafePointer<Void>) {
        self.imageView.image = image;
        self.imageView.accessibilityIdentifier = "Untitled.jpg";

        if let _ = didFinishSavingWithError {
            let alert = UIAlertView(title: "Save failed", message: "Failed to save image", delegate: nil, cancelButtonTitle:"OK", otherButtonTitles:"")
                alert.show()
        }
   }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }

    func extractImageAsMultipartParams() -> [String: AnyObject] {
        // extract the image filename
        let filename = self.imageView.accessibilityIdentifier;

        let multiPartData = MultiPartData(data: UIImageJPEGRepresentation(self.imageView.image!, 0.2)!,
            name: "image",
            filename: filename!,
            mimeType: "image/jpg")

        return ["file": multiPartData]
    }

    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

