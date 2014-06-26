AeroGear iOS Cookbook
=====================

The AeroGear iOS cookbook is a list of recipes to quick start your iOS AeroGear experience. This is a live version of the exact source code you can find [iOS cookbook documentation](http://aerogear.org/docs/guides/iOSCookbook/).

Each recipe is a complete iOS app. The goal of the recipes is to show you how easily you can use iOS AeroGear libraries and how it helps to achieve clean code. The app features are very lean and most of UI is kept to basics in order to focus on AeroGear library usage. 

## Table of content

| Recipe 	| Core 	| Push 	| Security 	|
| ------------- |:-------------:| :-----:|:-----:|
| [Cooking](Recipe/CookingRecipe.md): CRUD made easy with SQLite store | **Store** | - | - |
| [Shoot'n Share](Shoot/Shoot.md): Upload file to OAuth2 GoogleDrive | **File Upload** | - | OAuth2 |
| [AeroDoc](https://github.com/aerogear/aerogear-aerodoc-ios): Full exemple on how to register, received notification with Java backend | Store, Pipe | **Push** | Login |
| [HelloWorld](https://github.com/aerogear/aerogear-push-helloworld/ios): Simple demo of Push registration and notification handles with framework as dependencies | - | **Push** | - |
| [PushQuickstarts](https://github.com/aerogear/aerogear-push-quickstarts/tree/master/client/contacts-mobile-ios-client): Complete demo of UnifiedPush Server with server side | - | **Push** | - |
| [PushDemo](https://github.com/aerogear/aerogear-push-ios-demo): Simple demo of Push client registration with cocopods| - | **Push** | - |
| [Xmas](Xmas/Xmas.md): Demo how to encrypt/decrypt with crypto-lib | Store | - | **Encrypted API** |
| [CryptoDemo](https://github.com/aerogear/aerogear-crypto-ios-demo): Demo how to use Encrypted Storage | Store | - | **EncryptedStorage** |
| [OTP Demo](https://github.com/aerogear/aerogear-otp-ios-demo): How to use OTP client lib with a Java backend | - | - | **Login** |
| [Buddies](Buddies/README.md): Easy usage of Pipe with REST Java backend | **Pipe** | - | - |
| [GoogleDrive](GoogleDrive/GoogleDrive.md): OAuth2 to list all GoogleDrive documents | Pipe | - | **OAuth2** |
| [ProductInventory](ProductInventory/ProductInventory.md): Keycloak OAuth2 running with Keycloak server | Pipe | - | **OAuth2**', **Keycloak** |

Most of the recipes illustrate one main topic which is listed in bold in the table. Some examples demonstrate other aspects of the libraries so it is also listed in the different topics. For example, AeroDoc demo main purpose is to show you Push notifications, but it also uses Pipes, Stores and Login.

Some of the demos uses a [backend](https://github.com/aerogear/aerogear-integration-tests-server).

AeroGear features can be splitted into three main topics: 

* AeroGear Core: Store, Pipe, Paging, File upload etc...
* AeroGear Push: APN/GCM push notification, SimplePush
* AeroGear Security

For more details, please visit on [web site](http://aerogear.org/).

Some of the demos listed below are hold in separate repo, but as they follow the same philosophy (illustrate AeroGear libraries usage) we put a placeholder in the recipe cookbook for completeness. AeroDoc, HelloWorld, PushDemo, Push-Quickstarts have been added as git submodule, to fetch them:

    $ git submodule init

    $ git submodule update

## Building and installing each app

All our project require [CocoaPods](http://cocoapods.org/) for dependency management;

_BEFORE_ you can run the apps, you need to run the following command:

    pod install

After that you just need to open the ```app-name.xcworkspace``` file in XCode and you're all set.
