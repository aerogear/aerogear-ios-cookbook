Shoot'nShare
==============
You want to shoot cool photos and share them with friends using Google Drive or Facebook account?
With Shoot'nShare you can take picture, browse your camera roll, pick a picture and share it!
Picture get uploaded to your GoogleDrive or Facebook wall.
You can also run this demo with its associated [Keycloak backend](https://github.com/aerogear/aerogear-backend-cookbook/tree/master/Shoot) and upload photo to your own social network.

**NOTES:** System requirement: iOS8. Because this demo securely stores OAuth2 tokens in your iOS keychain, we chosen to use ```WhenPasscodeSet``` policy as a result to run this app you need to have **your passcode set**.
For more details see [WhenPasscodeSet blog post](http://corinnekrych.blogspot.fr/2014/09/new-kids-on-block-whenpasswordset.html) and [Keychain and WhenPasscodeSet blog post](http://corinnekrych.blogspot.fr/2014/09/touchid-and-keychain-ios8-best-friends.html)

### Run it in Xcode

The project uses utilizes [cocoapods](http://cocoapods.org) 0.36.0 pre-release for handling its dependencies. As a pre-requisite, install [cocoapods pre-release](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/) and then install the pod. On the root directory of the project run:

```bash
pod install
```
and then double click on the generated .xcworkspace to open in Xcode.

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
            <key>CFBundleURLSchemes</key>
            <array>
                <string>org.aerogear.Shoot</string>
                <string>fbYYY</string>
            </array>
        </dict>
    </array>

Replace YYY with your Facebook client id.

In ViewController.swift initializer, replace:

    // TODO replace XXX -> secret and YYY -> client id in this file + plist file
    let facebookConfig = FacebookConfig(
            clientId: "YYY",
            clientSecret: "XXX",
            scopes:["photo_upload, publish_actions"])
    self.facebook = FacebookOAuth2Module(config: facebookConfig)

with YYY with you client id and XXX with your client secret.

In AppDelegate.swift, add the callback method ```application:openURL:sourceApplication:annotation``` as below:

```
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        let notification = NSNotification(name: AGAppLaunchedWithURLNotification,
            object:nil,
            userInfo:[UIApplicationLaunchOptionsURLKey:url]) // [1]
        NSNotificationCenter.defaultCenter().postNotification(notification) //[2]
        return true
    }
```

In [1], we retrieve the url information containing authz code. To inform OAuth2 lib to carry on the OAuth2 dance post a notification in [2].

## Google setup
Here is the links and detailed setup instructions for Google Drive however as I noticed it is quite poorly documented for iOS app.

1. Have a Google account
2. Go to [Google cloud console](https://cloud.google.com/console#/project), create a new project
3. Go to __APIs & auth__ menu, then select __APIs__ and turn on __Drive API__
4. Always in __APIs & auth__ menu, select __Credentials__ and hit __create new client id__ button
Select iOS client and enter your bundle id.

NOTES:
Enter a correct bundle id as it will be use in URL schema to specify the callback URL.

Once completed you will have your information displayed as below:

![Google Cloud client registration](https://github.com/aerogear/aerogear-ios-cookbook/raw/master/Shoot/shoot_google_cloud_admin.png "Google Cloud client registration")

You get :

- Client Id
- Client Secret
- callback URL

Open Xcode, go to GoogleDrive-Info.plist and add an new URL schema entry as shown below:

![URL Scheme](https://github.com/aerogear/aerogear-ios-cookbook/raw/master/Shoot/url_schema.png "URL Scheme")

In AppDelegate.swift, add the callback method ```application:openURL:sourceApplication:annotation``` as explained in Facebook documetation.

## Keycloak setup

You will need an instance of Keycloak running locally please refer to [aerogear-backend-cookbook shoot recipe](https://github.com/aerogear/aerogear-backend-cookbook/tree/master/Shoot).

After that go to `ViewController.swift` and include the URL of Keycloak installation. For example:

```
@IBAction func shareWithKeycloak() {
    println("Perform photo upload with Keycloak")
    // Replace by your host here
    let keycloakHost = "https://shoot-aerogear.rhcloud.com"
    let keycloakConfig = KeycloakConfig(
        clientId: "shoot-third-party",
        host: keycloakHost,
        realm: "shoot-realm")

    let gdModule = AccountManager.addKeycloakAccount(keycloakConfig)
    self.http.authzModule = gdModule
    self.performUpload("\(keycloakHost)/shoot/rest/photos", parameters: self.extractImageAsMultipartParams())

}

```


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
