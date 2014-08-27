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

To run it, just hit the run button on Xcode.

The source code of [aerogear-ios-http](https://github.com/aerogear/aerogear-ios-http) library is contained in ../libs/AeroGearHttp shared folder.

> **NOTE:** Hopefully in the future and as the Swift language and tools around it mature, more straightforward distribution mechanisms will be employed using e.g [cocoapods](http://cocoapods.org) and framework builds. Currently neither cocoapods nor binary framework builds support Swift. For more information, consult this [mail thread](http://aerogear-dev.1069024.n5.nabble.com/aerogear-dev-Swift-Frameworks-Static-libs-and-Cocoapods-td8456.html) that describes the current situation.

Application Flow
----------------

### Registration

When the application is launched, you get to know aerogear team:

![import](buddies_swift.png)
