GoogleDrive
==============

GoogleDrive app displays, in a TableView, the documents in your Google Drive using OAuth2 to authenticate and authorize. The main purpose of this demo app is to show you how to use [aerogear-ios](https://github.com/aerogear/aerogear-ios) to manage OAuth2 transparently. 

## Install
All our project require [CocoaPods](http://cocoapods.org/) for dependency management;

**Before**, you can run the apps, you need to run the following command:

    pod install

After that you just need to open the ```GoogleDrive.xcworkspace``` file in XCode and you're all set.

## Google setup
We're using Google Drive as an example, similar code could be used for facebook or any OAuth2 provider. To set up you environment, refer to your provider. I give you the links and detailled setup for GoogleDrive however as I noticed it is quite pooly documented for iOS app.

1. Have a Google account
2. Go to [Google cloud console](https://cloud.google.com/console#/project), create a new project
3. Go to __APIs & auth__ menu, then select __APIs__ and turn on __Drive API__
4. Always in __APIs & auth__ menu, select __Credentials__ and hit __create new client id__ button
Select iOS client and enter your bundle id. 

NOTES:
Enter a correct bundle id as it will be use in URL schema to specify the callback URL.

Once completed you will have your information displayed as below: 

![GoogleDrive client registration](https://github.com/aerogear/aerogear-ios-cookbook/raw/master/GoogleDrive/GoogleDrive/Resources/images/client_id.png "GoogleDrive client registration")

You get :

- Client Id
- Client Secret
- callback URL 

Open Xcode, go to GoogleDrive-Info.plist and add an new URL schema entry as shown below:

![GoogleDrive URL Scheme](https://github.com/aerogear/aerogear-ios-cookbook/raw/master/GoogleDrive/GoogleDrive/Resources/images/callback_URL.png "GoogleDrive URL Scheme")

## OAuth2 Flow

### Step1: request access token, get an access code 
- The app calls authorization URL _https://accounts.google.com/o/oauth2/auth_ 
- The user is prompted to authenticate and authorize

## Step2: user login & consent
- Once successfully authenticated and granted access, the app is given an __access code__

### Step3: Exchange access code for access token
- Doing a call to _https://accounts.google.com/o/oauth2/token_
- Access code get exchanged with access token

### Step4: Call Google Drive API
Once authorization is done, you can do anything you wish, refer to the [Google Drive API](https://developers.google.com/drive/v2/reference/).

![Google OAuth2](https://github.com/aerogear/aerogear-ios-cookbook/raw/master/GoogleDrive/GoogleDrive/Resources/images/OAuth2_flow.png "Google OAuth2")

## AeroGear OAuth2

Let's delve into the code an get a step by step approach:

In AGViewController.m:

	- (IBAction)authorize:(UIButton *)sender {
	    AGAuthorizer* authorizer = [AGAuthorizer authorizer];
	    
	    _restAuthzModule = [authorizer authz:^(id<AGAuthzConfig> config) {				[1]
	        config.name = @"restAuthMod";
	        config.baseURL = [[NSURL alloc] initWithString:@"https://accounts.google.com"];
	        config.authzEndpoint = @"/o/oauth2/auth";
	        config.accessTokenEndpoint = @"/o/oauth2/token";
	        config.clientId = @"XXXXX";
	        config.redirectURL = @"org.aerogear.GoogleDrive:/oauth2Callback";
	        config.scopes = @[@"https://www.googleapis.com/auth/drive"];
	    }];
	    
	    [_restAuthzModule requestAccessSuccess:^(id object) {							[2]
	        [self fetchGoogleDriveDocuments:_restAuthzModule];							[4]
	    } failure:^(NSError *error) {
	    }];
	}

In AGAppDelegate.m:

	- (BOOL)application:(UIApplication *)application
	            openURL:(NSURL *)url
	  sourceApplication:(NSString *)sourceApplication
	         annotation:(id)annotation
	{																					[3]
	    NSNotification *notification = [NSNotification notificationWithName:@"AGAppLaunchedWithURLNotification" 
	    object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:@"UIApplicationLaunchOptionsURLKey"]];
	    [[NSNotificationCenter defaultCenter] postNotification:notification];
	    
	    return YES;
	}

In AGViewController.m:

	-(void)fetchGoogleDriveDocuments:(id<AGAuthzModule>) authzModule {
	    NSString* readGoogleDriveURL = @"https://www.googleapis.com/drive/v2";
	    NSURL* serverURL = [NSURL URLWithString:readGoogleDriveURL];
	    AGPipeline* googleDocuments = [AGPipeline pipelineWithBaseURL:serverURL];
	    
	    id<AGPipe> documents = [googleDocuments pipe:^(id<AGPipeConfig> config) {		[5]
	        [config setName:@"files"];
	        [config setAuthzModule:authzModule];										[6]
	    }];
	    
	    [documents read:^(id responseObject) {											[7]
	        _documents = [[self buildDocumentList:responseObject[0]] copy];
	        [self.tableView reloadData];
	    } failure:^(NSError *error) {
	        // when an error occurs... at least log it to the console..
	        NSLog(@"Read: An error occured! \n%@", error);
	    }];
	}


[1]: configuration with all required URLs and endpoints.


[2]: requestAccessSuccess:failure: is the method dealing with all the steps needed to authorize.


[3]: once popup has been answered, go back to GoogleDrive app and notified AeroGear framework. If this method is not well implemented, the browser won't be able to callback the application. Back to the app, access code is excahnge with access token (step 2).


[4]: the success callback takes the access token as parameter. The access token is stored in memory with AGAuthzModule. It's up to the developer to store permanently the access token for next app launch. Note that access token has an expiration date (1h for Google).


[5]: create your Pipeline and Pipe objects as usual. 


[6]: setting authz module in your pipe configuration will pass the access token for each pipe operations transparently.


[7]: read the pipe as usual.

