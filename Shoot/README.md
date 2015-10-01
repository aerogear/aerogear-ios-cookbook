Shoot'nShare
==============
You want to shoot cool photos and share them with friends using Google Drive or Facebook account?
With Shoot'nShare you can take picture, browse your camera roll, pick a picture and share it!
Picture get uploaded to your GoogleDrive or Facebook wall.
You can also run this demo with its associated [Keycloak backend](https://github.com/aerogear/aerogear-backend-cookbook/tree/master/Shoot) and upload photo to your own social network.

Supported platforms: iOS7, iOS8, iOS9.

**NOTES:** On iOS8, this demo securely stores OAuth2 tokens in your iOS keychain, we chosen to use ```WhenPasscodeSet``` policy as a result to run this app you need to have **your passcode set**.
For iOS7, the ```WhenUnlockedThisDeviceOnly``` is choosen, no need of passcode to be set.
For more details see [WhenPasscodeSet blog post](http://corinnekrych.blogspot.fr/2014/09/new-kids-on-block-whenpasswordset.html) and [Keychain and WhenPasscodeSet blog post](http://corinnekrych.blogspot.fr/2014/09/touchid-and-keychain-ios8-best-friends.html)

### Run it in Xcode

The project uses [cocoapods](http://cocoapods.org) or handling its dependencies. As a pre-requisite, install [cocoapods](http://cocoapods.org) and then install the pod. On the root directory of the project run:

```bash
pod install
```
and then double click on the generated .xcworkspace to open in Xcode.

For the complete instructions about how to setup Google, Facebook or Keycloak credentials, visit our [OAuth2 documentation guide](https://aerogear.org/docs/guides/security/oauth2-guide/#_before_you_get_started)

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
        //googleConfig.isWebView = true                               // [2]
        let gdModule = AccountManager.addGoogleAccount(googleConfig)  // [3]
        let http = Http(url: "https://www.googleapis.com/upload/drive/v2/files")
        http.authzModule = gdModule                                   // [4]
        self.performUpload(http, parameters: self.extractImageAsMultipartParams())
    }
```
In [1] initialize config. The default config uses an external browser approach when lauching the authorization request (ie: Safari opens to prompt you for your credentials). If you prefer to use an embedded webview, uncomment line [2].

You can use AccountManager to create an OAuth2Module in [3]

Simply create an http object and inject the oauth2 module [4], then all headers will be added for you when you do http.POST/GET etc...
