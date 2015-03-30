AeroDoc
=======
Level: Beginner  
Technologies: ObjC, iOS  
Summary: A tutorial application to demonstrate how to build an application using Unified Push server. 

What is it?
-----------

AeroDoc is an tutorial application to demonstrate how to build an application using Unified Push server. 

You're a developper and you want to use AeroGear Unified Push Server to develop AeroDoc, a backend RESTful application with iOS client to create new leads and send them as push notifications to sale agents. 

If you want to know more about AeroDoc description, see [aerogear-aerodoc-backend](https://github.com/aerogear/aerogear-aerodoc-backend/blob/master/readme.md#description-of-the-application)

This repo focus on iOS client app. But before running the app, you'll need some setup. 

System requirements
-------------------
- iOS 7.X
- Xcode version 6.1.1 and later

Setup
-----

 * in [config file](https://github.com/aerogear/aerogear-aerodoc-ios/blob/master/AeroDoc/AeroDoc/Classes/Config/AGConfig.h), replace:

```c
  #define URL_AERODOC @"http://localhost:8080/aerodoc/"
  #define URL_UNIFIED_PUSH @"http://localhost:8080/ag-push/"
  #define VARIANT_ID @"YOUR_VARIANT"
  #define VARIANT_SECRET @"YOUR_SECRET"
  #define ENDPOINT @"rest"
```

 * make sure bundle id of app matches the one in provisioning device

Build and Deploy AeroDoc
------------------------

The project uses [cocoapods](http://cocoapods.org). As a pre-requisite, install [cocoapods](http://blog.cocoapods.org/CocoaPods-0.36/) and then install the pod. On the root directory of the project run:

```bash
pod install
```

and then double click on the generated .xcworkspace to open in Xcode.
