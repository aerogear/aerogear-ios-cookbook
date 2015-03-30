GoogleDrive
===========
Level: Beginner  
Technologies: ObjC, iOS  
Summary: A basic example of OAuth2 : Login and retrieve data.

What is it?
-----------

GoogleDrive app displays in a TableView, all your documents in your Google Drive using OAuth2 to authenticate and authorize. The main purpose of this demo app is to show you how to use [aerogear-ios](https://github.com/aerogear/aerogear-ios) to manage OAuth2 transparently. 

System requirements
-------------------
- iOS 7.X
- Xcode version 6.1.1 and later

For the complete instructions about how to setup Google credentials, visit our [OAuth2 documentation guide](https://aerogear.org/docs/guides/security/oauth2-guide/#Google).

Setup
-----
In [AGViewController.m](https://github.com/aerogear/aerogear-ios-cookbook/blob/1.6.x/GoogleDrive%2FGoogleDrive%2FAGViewController.m#L156), replace with your google client id.

Open Xcode, go to [GoogleDrive-Info.plist](https://github.com/aerogear/aerogear-ios-cookbook/blob/1.6.x/GoogleDrive%2FGoogleDrive%2FGoogleDrive-Info.plist#L29) and add an new URL schema entry as shown below:

![GoogleDrive URL Scheme](https://github.com/aerogear/aerogear-ios-cookbook/raw/1.6.x/GoogleDrive/GoogleDrive/Resources/images/callback_URL.png "GoogleDrive URL Scheme")
