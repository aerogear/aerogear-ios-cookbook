Buddies
=======
Level: Beginner  
Technologies: Swift, iOS  
Summary: A basic example of aerogear-ios-http  

What is it?
-----------

This project is a very simple app, to show how to do a http call against a simple REST endpoint. The demo is implemented in [Swift](https://developer.apple.com/swift/) and uses the [aerogear-ios-http](https://github.com/aerogear/aerogear-ios-http) library. Backend REST endpoint is implemented in this [repo](https://github.com/aerogear/aerogear-integration-tests-server). For convenience an [OpenShift instance](http://igtests-cvasilak.rhcloud.com/rest/team/developers) has been deployed. Please make sure it is not idle before running the app, by hitting the URL in your browser. 

System requirements
-------------------
- iOS 8.X
- Xcode version 6 Beta 6

Configure
---------
Either run a [backend instance locally](https://github.com/aerogear/aerogear-integration-tests-server) or use this [OpenShift instance](http://igtests-cvasilak.rhcloud.com/rest/team/developers). 


Build and Deploy Buddies
------------------------

### Change URL

If you deploy the backend locally, in ViewController.swift, update the URL:

```swift
override func viewDidLoad() {
    super.viewDidLoad()   
    var http = AGSessionImpl(url: "http://igtests-cvasilak.rhcloud.com/rest/team/developers", sessionConfig: NSURLSessionConfiguration.defaultSessionConfiguration())
...
}
```

### Run it in Xcode

The project uses utilizes [cocoapods](http://cocoapods.org) 0.36.0 pre-release for handling its dependencies. As a pre-requisite, install [cocoapods pre-release](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/) and then install the pod. On the root directory of the project run:

```bash
pod install
```

and then double click on the generated .xcworkspace to open in Xcode.

Application Flow
----------------

### Registration

When the application is launched, you get to know aerogear team:

![import](buddies_swift.png)
