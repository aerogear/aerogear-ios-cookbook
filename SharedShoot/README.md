SharedShoot
===========
Playing well with Shoot'nShare app, SharedShoot allows you to see all the pictures shared via [Keycloak backend](https://github.com/aerogear/aerogear-backend-cookbook/tree/master/Shoot) and download photos from your friends.
You login using OpenID Connect.

Supported platforms: iOS8, iOS9, iOS10.

**NOTES:** This demo securely stores OAuth2 tokens in your iOS keychain, we chosen to use ```WhenPasscodeSet``` policy as a result to run this app you need to have **your passcode set**. You can't test it on the Simulator.
For more details see [WhenPasscodeSet blog post](http://corinnekrych.blogspot.fr/2014/09/new-kids-on-block-whenpasswordset.html) and [Keychain and WhenPasscodeSet blog post](http://corinnekrych.blogspot.fr/2014/09/touchid-and-keychain-ios8-best-friends.html)

### Run it in Xcode

The project uses [CocoaPods](http://cocoapods.org) for handling its dependencies. As a pre-requisite, install [CocoaPods](http://blog.cocoapods.org/) and then install the pod. On the root directory of the project run:

```bash
pod install
```
Then double click on the generated .xcworkspace to open in Xcode.

Open SharedShoot/ViewController.swift, change HOST url replacing localhost with the local IP of your computer.

And finally, run the app in your device.