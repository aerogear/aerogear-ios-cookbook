Shoot'nShare
==============
You want to shoot cool photos and share them with friends using GoogleDrive or Facebook account?
With Shoot'nShare you can take picture, browse your camera roll, pick a picture and share it!
Picture get uploaded to your GoogleDrive or Facebook wall.
You can also run this demo with its associated [Keycloak backend](https://github.com/aerogear/aerogear-backend-cookbook/tree/master/Shoot) and upload photo to your own social network.

**NOTES:** System requirement: iOS8. Because this demo securely stores OAuth2 tokens in your iOS keychain, we chosen to use ```WhenPasscodeSet``` policy as a result to run this app you need to have **your passcode set**.
For more details see [WhenPasscodeSet blog post](http://corinnekrych.blogspot.fr/2014/09/new-kids-on-block-whenpasswordset.html) and [Keychain and WhenPasscodeSet blog post](http://corinnekrych.blogspot.fr/2014/09/touchid-and-keychain-ios8-best-friends.html)

## Facebook setup 

### Step1: Setup facebook to be a facebook developer:

- Go to [Facebook dev console](https://developers.facebook.com/products/login/)
- Click Apps->Register as a Developer
- enter password
- accept policy
- send confirmation code to SMS
- once received enter code

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

In ViewController.swift initializer, replace:

    // TODO replace XXX -> secret and YYY-> appid in this file + plist file
    let facebookConfig = FacebookConfig(
            clientId: "YYY",
            clientSecret: "XXX",
            scopes:["photo_upload, publish_actions"])
    self.facebook = FacebookOAuth2Module(config: facebookConfig)

with YYY with you appId and XXX with your client secret.

## Google setup (optional)
Here is the links and detailed setup instructions for GoogleDrive however as I noticed it is quite poorly documented for iOS app.

NOTES: This step is optional if your want to try the GoogleDrive app out of the box. The client id for 'GoogleDrive' has already been generated and [is available in the app](https://github.com/aerogear/aerogear-ios-cookbook/blob/master/GoogleDrive/GoogleDrive/AGViewController.m#L75). However if you want to create your own app, you will have to go through your provider setup instruction. Here's how to do it for Google Drive.

1. Have a Google account
2. Go to [Google cloud console](https://cloud.google.com/console#/project), create a new project
3. Go to __APIs & auth__ menu, then select __APIs__ and turn on __Drive API__
4. Always in __APIs & auth__ menu, select __Credentials__ and hit __create new client id__ button
Select iOS client and enter your bundle id.

NOTES:
Enter a correct bundle id as it will be use in URL schema to specify the callback URL.

Once completed you will have your information displayed as below:

![Google Cloud client registration]((https://github.com/aerogear/aerogear-ios-cookbook/raw/master/Shoot/shoot_google_cloud_admin.png "Google Cloud client registration")

You get :

- Client Id
- Client Secret
- callback URL

Open Xcode, go to GoogleDrive-Info.plist and add an new URL schema entry as shown below:

![URL Scheme](https://github.com/aerogear/aerogear-ios-cookbook/raw/master/Shoot/url_schema.png "URL Scheme")


## Keycloak setup

You will need an instance of Keycloak running locally please refer to [aerogear-backend-cookbook shoot recipe](https://github.com/aerogear/aerogear-backend-cookbook/tree/master/Shoot).

## UI Flow 
When you start the application you can take picture or select one from your camera roll.

Once an image is selected, you can share it. Doing so, you trigger the OAuth2 authorization process. Once successfully authorized, your image will be uploaded.

NOTES: Because this app uses your camera, you should run it on actual device. Running on simulator won't allow camera shoot.

## AeroGear OAuth2

```
    func shareWithGoogleDrive() {
        println("Perform photo upload with Google")
        
        let googleConfig = GoogleConfig(                              // [1]
            clientId: "873670803862-g6pjsgt64gvp7r25edgf4154e8sld5nq.apps.googleusercontent.com",
            scopes:["https://www.googleapis.com/auth/drive"])

        let gdModule = AccountManager.addGoogleAccount(googleConfig)  // [2]
        let http = Http(url: "https://www.googleapis.com/upload/drive/v2/files")
        http.authzModule = gdModule                                   // [3]
    
        self.performUpload(http, parameters: self.extractImageAsMultipartParams())
    }
```
In [1] initialize config

You can use AccountManager to create an OAuth2Module in [2]

Simply create an http object and inject the oauth2 module [3], then all headers will be added for you when you do http.POST/GET etc...