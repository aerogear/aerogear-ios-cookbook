helloworld-push-ios: Basic Mobile Application showing the AeroGear Push feature on iOS
======================================================================================
Author: Corinne Krych (ckrych), Christos Vasilakis (cvasilak)
Level: Beginner  
Technologies: Swift 4.0, iOS
Summary: A basic example of Push : Registration and receiving messages.  
Target Product: Mobile  
Product Versions: MP 1.0
Source: https://github.com/aerogear/aerogear-push-helloworld/ios-swift

What is it?
-----------

This project is a very simple helloworld, to show how to get started with the UnifiedPush Server on iOS. The demo is implemented in [Swift 4.0](https://developer.apple.com/swift/) and uses the push-sdk [Swift|https://github.com/aerogear/aerogear-ios-push/tree/master] for registering to the UnifiedPush Server.

System requirements
-------------------
- iOS 9, iOS 10, iOS 11
- Xcode version 9.0+

Configure
---------
* Have created an variant in UnifiedPush admin console
* Have a valid provisioning profile as you will need to test on device (push notification not available on simulator)
* Replace the bundleId with your bundleId (the one associated with your certificate).
Go to HelloWorldSwift target -> Info -> change Bundle Identifier field.

![change HelloWorldSwift bundle](../ios-swift/doc/change-helloworld-bundle.png)

Build and Deploy the HelloWorld
-------------------------------

The project uses [CocoaPods](http://cocoapods.org) for handling its dependencies. As a pre-requisite, install [CocoaPods](http://cocoapods.org) and then install the pod. On the root directory of the project run:


```bash
pod install
```

and then double click on the generated `HelloWorldSwift.xcworkspace` to open in Xcode.

### Change Push Configuration

In `HelloWorldSwift/Supporting Files/pushconfig.plist` fill the values for serverURL, variantID and variantSecret.

Application Flow
----------------------

### Registration

When the application is launched, AppDelegate's `application:didFinishLaunchingWithOptions:` registers the app to receive remote notifications.

Note that _registerForRemoteNotificationTypes:_ has been removed in iOS8 in favor of _registerUserNotificationSettings:_ and _registerForRemoteNotifications_

```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let settings = UIUserNotificationSettings(types: .alert | .badge | .sound, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
        ...
        return true
    }
```

Therefore, AppDelegate's `application:didRegisterForRemoteNotificationsWithDeviceToken:` will be called.

When AppDelegate's `application:didRegisterForRemoteNotificationsWithDeviceToken:` is called, the device is registered to UnifiedPush Server instance. This is where configuration changes are required (see code snippet below).

### Sending message
Now you can send a message to your device by clicking `Compose Message...` from the application page. Write a message in the text field and hit 'Send Push Message'.

![import](../cordova/doc/compose-message.png)

After a while you will see the message end up on the device.

When the application is running in foreground, you can catch messages in AppDelegate's  `application:didReceiveRemoteNotification:`. The event is forwarded using `NSNotificationCenter` for decoupling appDelegate and ViewController. It will be the responsability of ViewController's `messageReceived:` method to render the message on UITableView.

When the app is running in background, user can bring the app in the foreground by selecting the Push notification. Therefore AppDelegate's  `application:didReceiveRemoteNotification:` will be triggered and the message displayed on the list. If a background processing was needed we could have used `application:didReceiveRemoteNotification:fetchCompletionHandler:`. Refer to [Apple documentation for more details](https://developer.apple.com/library/ios/documentation/uikit/reference/UIApplicationDelegate_Protocol/Reference/Reference.html#//apple_ref/occ/intfm/UIApplicationDelegate/application:didReceiveRemoteNotification:fetchCompletionHandler:)

For application not running, we're using AppDelegate's `application:didFinishLaunchingWithOptions:`, we locally save the latest message and forward the event to ViewController's `messageReceived:`.

**NOTE**: The local save is required here because of the asynchronous nature of `viewDidLoad` vs `application:didFinishLaunchingWithOptions:`


FAQ
--------------------

* Which iOS version is supported by AeroGear iOS libraries?

AeroGear supports iOS 9.X+


Debug the Application
=====================

Set a break point in Xcode.
