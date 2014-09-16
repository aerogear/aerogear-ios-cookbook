Shoot'nShare
==============
You want to shoot cool photos and share them with friends using GoogleDrive or Facebook account?
With Shoot'nShare you can take picture, browse your camera roll, pick a picture and share it!
Picture get uploaded to your GoogleDrive or Facebook wall.

## Facebook setup 

### Step1: Setup facebook to ba a facebook developer:

- Go to [Facebook dev console](https://developers.facebook.com/products/login/)
- Click Apps->Register as a Developper
- enter password
- accept policy
- send confirmation code to SMS
- once recieved enter code

### Step2: Create a new app on facebook console

- Click apps-> Create a new app
- add display name: Shoot
- deal with difficult catcha
- configure Advanced setup:
	- Native or desktop app? NO
	- Client OAuth Login YES
	- Embedded browser OAuth Login YES

### Step3: Configure Shoot app iOS client

In Shoot-Info.plist

        <key>CFBundleURLTypes</key>
        <array>
            <dict>
                <key>CFBundleURLName</key>
                <string>fbYYY</string>
                <key>CFBundleURLSchemes</key>
                <array>
                    <string>fbYYY</string>
                </array>
            </dict>
        </array>

Replace by fbYYY where YYY is your app id.

In ViewController.swift initialiazer, replace:

    // TODO repalce XXX -> secret and YYY->appid in this file + plist file
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

with YYY with you appId and XXX with your client secret.

## Google setup (optional)

Similar setup than [GoogleDrive app](../GoogleDrive/GoogleDrive.md) please refer to its configuration section. 
NOTES: Google setup has already been done for Shoot'nShare app. You can use out of the box. If you want to create your own app, please follow set instructions.

## UI Flow 
When you start the application you can take picture or select one from your camera roll.

Once an image is selected, you can share it. Doing so, you trigger the OAuth2 authorization porcess. Once successfully authorized, your image will be uploaded.

![Shoot'nShare app](https://github.com/aerogear/aerogear-ios-cookbook/raw/master/Shoot/Shoot/Resources/shootupload.png "Shoot")

NOTES: Because this app uses your camera, you should run it on actual device. Running on simulator won't allow camera shoot.

## AeroGear upload

How does it work?

    func performUpload(http: Http) {
        // extract the image filename
        let filename = self.imageView.accessibilityIdentifier; 
    
        // Get currently displayed image
        let imageData = UIImageJPEGRepresentation(self.imageView.image, 0.2); // [1]
        
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

[1] you convert your image into binary format with a compression ratio (high compression of 0.2)


[2] TODO 

