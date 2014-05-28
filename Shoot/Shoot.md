Shoot'nShare
==============
You want to shoot cool photos and share them with friends using GoogleDrive.
With ShootnShare you can take picture, browse your camera roll, pick a picture to share and share it!
Picture get uploaded to your GoogleDrive.

## Install
All our project require [CocoaPods](http://cocoapods.org/) for dependency management;

**Before**, you can run the apps, you need to run the following command:

    pod install

After that you just need to open the ```Shoot.xcworkspace``` file in XCode and you're all set.


## Facebook setup 

### Step1: Setup facebook to be a facebook developer:

- Go to [Facebook dev console](https://developers.facebook.com/products/login/)
- Click Apps->Register as a Developper
- enter password
- accept policy
- send confirmation code to SMS
- once recieved enter code

### Step2: Create a new app on facebook console

- Click apps -> Create a new app
- add display name: Shoot
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
                <string>fb240176532852375</string>
                <key>CFBundleURLSchemes</key>
                <array>
                    <string>fb240176532852375</string>
                </array>
            </dict>
        </array>

Replace by fbYYY where YYY is your app id.

In AGShootViewController.m:

    // TODO repalce XXX -> secret and YYY->appid in this file + plist file
    _restAuthzModule = [authorizer authz:^(id<AGAuthzConfig> config) {
        config.name = @"restAuthMod";
        config.baseURL = [[NSURL alloc] init];
        config.authzEndpoint = @"https://www.facebook.com/dialog/oauth";
        config.accessTokenEndpoint = @"https://graph.facebook.com/oauth/access_token";
        config.clientId = @"YYY";
        config.clientSecret = @"XXX"; //required although stated shouldn't be asked for authorization grant as per Oauth2 spec
        config.redirectURL = @"fbYYY://authorize/";
        config.scopes = @[@"user_friends, public_profile"];
    }];

with YYY with you appId and XXX with your client secret.

## Google setup (optional)

Similar setup than [GoogleDrive app](../GoogleDrive/GoogleDrive.md) please refer to its configuration section. 
NOTES: Google setup has already been done for ShootnShare app. You can use out of the box. If you want to create your own app, please follow set instructions.

## UI Flow 
When you start the application you can take picture or select one from your camera roll.

Once an image is selected, you can share it. You can select either Google or Facebook social network.

Because Shoot uses a permanent storage account manager, you will be prompted for access grant once per provider.

NOTES: Be aware that the storeage type is PLIST therefore your access and refresh token will be stored in clear. For a more secure flow choose, an encrypted storage.

Once successfully authorized, your image will be uploaded.

![Shoot'nShare app](https://github.com/aerogear/aerogear-ios-cookbook/raw/master/Shoot/Shoot/Resources/shootupload.png "Shoot")

NOTES: Because this app uses your camera, you should run it on actual device. Running on simulator won't allow camera shoot.

## AeroGear Account Manager

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *accountId = [prefs stringForKey:@"facebook"];
    
    // Create a permanent (non-encrypted) Account Manager
    AGAccountManager* accountManager = [AGAccountManager manager:@"PLIST"];		// [1]
    // Create an account and an authzmodule
    _facebookAuthzModule = [accountManager authz:^(id<AGAuthzConfig> config) {	// [2]
        config.accountId = accountId;											// [3]
        config.name = @"restAuthMod";
        config.baseURL = [[NSURL alloc] init];
        config.authzEndpoint = @"https://www.facebook.com/dialog/oauth";
        config.accessTokenEndpoint = @"https://graph.facebook.com/oauth/access_token";
        config.clientId = @"XXX";
        config.clientSecret = @"27c1f30169956c38169e668345b35229";
        config.redirectURL = @"fb240176532852375://authorize/";
        config.scopes = @[@"photo_upload, publish_actions"];
        config.type = @"AG_OAUTH2_FACEBOOK";

    }];
    _accounts[@"facebook"] = _facebookAuthzModule.accountId;
    [prefs setObject:_facebookAuthzModule.accountId forKey:@"facebook"];		// [4]
    
    [_facebookAuthzModule requestAccessSuccess:^(id response) {
        
        [self shareWithFacebook];
        NSLog(@"Success to authorize %@", response);
        
    } failure:^(NSError *error) {
        NSLog(@"Failure to authorize");
    }];

[1] Create an AGAccountManager that will store access token and refresh token in a PLIST
[2] Ask AGAccountManager for an authorization module, if accountId [3] is nil in the configuration, a new one will be created and assigned an UUID.
[4] Store AccountId to be able to retrieve it when you launch your app a second time
[5] From the authorization module request access. If the account already contain access code, do no ask for grant, if no access code, user will be prompt to grant access. Once access and refresh tokens are given to authzModule, they will be transparently refreshed and stored in AGAccountManager.



## AeroGear upload

How does it work?

	-(void)upload:(id<AGAuthzModule>) authzModule token:(NSString*)object{
	    NSString* uploadGoogleDriveURL = @"https://www.googleapis.com/upload/drive/v2";
	    NSURL* serverURL = [NSURL URLWithString:uploadGoogleDriveURL];
	    
	    AGPipeline* googleDocuments = [AGPipeline pipelineWithBaseURL:serverURL];
	    
	    id<AGPipe> pipe = [googleDocuments pipe:^(id<AGPipeConfig> config) {
	        [config setName:@"files"];
	        [config setAuthzModule:authzModule];
	    }];
	    // Get image with high compression
	    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.2); // [1]
	    AGFileDataPart *dataPart = [[AGFileDataPart alloc] 
	    	initWithFileData:imageData
	        name:@"image"
	        fileName:@"image.jpeg" 
	        mimeType:@"image/jpeg"]; 						// [2]
	    // set up payload
	    NSDictionary *dict = @{@"data:": dataPart};
	    [pipe save:dict success:^(id responseObject) {		// [3]
	        NSLog(@"Successfully uploaded!");
	        
	    } failure:^(NSError *error) {
	        NSLog(@"An error has occured during upload! \n%@", error);
	    }];
	}

[1] you convert your image into binary format with a compression ratio (high compression of 0.2)


[2] you build the first part of the upload wrapped into a AGFileDataPart object


[3] you add it to the dictionnary object to save and very transparently you save your data within the pipe.
