AeroGear iOS Cookbook
=====================

The AeroGear iOS cookbook is a list of recipes to quick start your iOS AeroGear experience. This is a live version of the exact source code you can find [iOS cookbook documentation](http://aerogear.org/docs/guides/iOSCookbook/).

Each recipe is a complete iOS app. The goal of the recipes is to show you how easily you can use iOS AeroGear libraries and how it helps to achieve clean code. The app features are very lean and most of UI is kept to basics in order to focus on AeroGear library usage. 

## Table of content

| Recipe 	| Core 	| Push 	| Security 	|
| ------------- |:-------------:| :-----:|:-----:|
| [Cooking](Recipe/CookingRecipe.md) | **Store** | - | - |
| Shoot'n Share | **File Upload** | - | - |
| [AeroDoc](https://github.com/aerogear/aerogear-aerodoc-ios) | Store, Pipe | **Push** | Login |
| [Xmas](Xmas/Xmas.md) | Store | - | **Encrypted API** |
| [CryptoDemo](https://github.com/aerogear/aerogear-crypto-ios-demo) | Store | - | **EncryptedStorage** |
| [OTP Demo](https://github.com/aerogear/aerogear-otp-ios-demo) | - | - | **Login** |
| [PipeDemo](PipeDemo/README.md) | **Pipe** | - | - |

Most of the recipes illustrate one main topic which is listed in bold in the table. Some examples demonstrate other aspects of the libraries so it is also listed in the different topics. For example, AeroDoc demo main purpose is to show you Push notifications, but it also uses Pipes, Stores and Login.

AeroGear features can be splitted into three main topics: 
* AeroGear Core: Store, Pipe, Paging, File upload etc...
* AeroGear Push: APN/GCM push notification, SimplePush
* AeroGear Security
For more details, please visit on [web site](http://aerogear.org/).

Some of the demos listed below are hold in separate repo, but as they follow the same philosophy (illustrate AeroGear libraries usage) we put a placeholder in the recipe cookbook for completeness.

	NOTE: This is a work in progress more recipe app will be added shortly. Stay tuned. 

## Building and installing each app

All our project require [CocoaPods](http://cocoapods.org/) for dependency management;

_BEFORE_ you can run the apps, you need to run the following command:

    pod install

After that you just need to open the ```app-name.xcworkspace``` file in XCode and you're all set.
