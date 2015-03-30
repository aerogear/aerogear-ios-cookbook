AeroGear iOS Cookbook
=====================

The AeroGear iOS cookbook is a list of recipes to quick start your iOS AeroGear experience. 

Each recipe is a complete iOS app. The goal of the recipes is to show you how easily you can use iOS AeroGear libraries and how it helps to achieve clean code. The app features are very lean and most of UI is kept to basics in order to focus on AeroGear library usage. 

|                 | Project Info  |
| --------------- | ------------- |
| License:        | Apache License, Version 2.0  |
| Build:          | Cocoapods  |
| Documentation:  | https://aerogear.org/docs/guides/aerogear-ios/ |
| Issue tracker:  | https://issues.jboss.org/browse/AGIOS  |
| Mailing lists:  | [aerogear-users](http://aerogear-users.1116366.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-users))  |
|                 | [aerogear-dev](http://aerogear-dev.1069024.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-dev))  |

## Cookbook apps

| Recipe 	| Core 	| Push 	| Security 	|
| ------------- |:-------------:| :-----:|:-----:|
| [Cooking](Recipe/CookingRecipe.md): CRUD made easy with SQLite store | **Store** | - | - |
| [Shoot'n Share](Shoot/Shoot.md): Upload file to OAuth2 GoogleDrive | **File Upload** | - | OAuth2 |
| [AeroDoc](https://github.com/aerogear/aerogear-backend-cookbook/tree/master/aerodoc-backend): Full exemple on how to register, received notification with Java backend | Store, Pipe | **Push** | Login |
| [Xmas](Xmas/Xmas.md): Demo how to encrypt/decrypt with crypto-lib | Store | - | **Encrypted API** |
| [PasswordManager](PasswordManager/README.md): Demo how to use Encrypted Storage | Store | - | **EncryptedStorage** |
| [Two-Factor](Two-Factor/README.md): How to use OTP client lib with a Java backend | - | - | **Login** |
| [GoogleDrive](GoogleDrive/GoogleDrive.md): OAuth2 to list all GoogleDrive documents | Pipe | - | **OAuth2** |

## Other AeroGear iOS example apps

| Recipe    | Core  | Push  | Security  |
| ------------- |:-------------:| :-----:|:-----:|
| [Unified Push HelloWorld](https://github.com/jboss-mobile/unified-push-helloworld/ios): Simple demo of Push registration and notification handles with framework as dependencies | - | **push** | - |
| [Unified Push Quickstarts](https://github.com/jboss-mobile/unified-push-quickstarts/tree/master/client/contacts-mobile-ios-client): Complete demo of Push notification with server side using UnifiedPush server | - | **Push** | - |
| [PushDemo](https://github.com/aerogear/aerogear-push-ios-demo): Simple demo of Push client registration with cocopods| - | **Push** | - |

Most of the recipes illustrate one main topic which is listed in bold in the table. Some examples demonstrate other aspects of the libraries so it is also listed in the different topics. 

Some of the demos uses a [backend](https://github.com/aerogear/aerogear-backend-cookbook/).

Some of the demos listed below are hold in separate repo, but as they follow the same philosophy (illustrate AeroGear libraries usage) we put a placeholder in the recipe cookbook for completeness. HelloWorld, Push-Quickstarts, PushDemo have been added as git submodule, to fetch them:

    $ git submodule init && git submodule update

## Building and installing each app

All our project require [CocoaPods](http://cocoapods.org/) for dependency management;

_BEFORE_ you can run the apps, you need to run the following command:

    pod install

After that you just need to open the ```app-name.xcworkspace``` file in XCode and you're all set.
