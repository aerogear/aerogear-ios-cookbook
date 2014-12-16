AeroGear iOS Cookbook
=====================

> Recipe app build with Xcode6.1.1

The AeroGear iOS cookbook is a list of recipes to quick start your iOS AeroGear experience. 

Each recipe is a complete iOS app. The goal of the recipes is to show you how easily you can use iOS AeroGear libraries and how it helps to achieve clean code. The app features are very lean and most of UI is kept to basics in order to focus on AeroGear library usage. 

## Table of content

| Recipe 	| Core 	| Push 	| Security 	|
| ------------- |:-------------:| :-----:|:-----:|
| [Weather](Weather/README.md): geo-loation based app to fetch information using http lib | **http** | - | - |
| [Buddies](Buddies/README.md): Simple demo for http usage and serialization | **http** | - | - |
| [HelloWorld](https://github.com/aerogear/aerogear-push-helloworld/ios): Simple demo of Push registration and notification handles with framework as dependencies | - | **push** | - |
| [PushQuickstarts](https://github.com/aerogear/aerogear-push-quickstarts/tree/master/client/contacts-mobile-ios-client): Complete demo of Push notification with server side using UnifiedPush server | - | **Push** | - |
| [Shoot](Shoot/README.md): oauth2 sharing photo, web-app to display photos | http, **oauth2** | - | - |

Most of the recipes illustrate one main topic which is listed in bold in the table. Some examples demonstrate other aspects of the libraries so it is also listed in the different topics. 

Some of the demos uses a [backend](https://github.com/aerogear/aerogear-integration-tests-server).

Some of the demos listed below are hold in separate repo, but as they follow the same philosophy (illustrate AeroGear libraries usage) we put a placeholder in the recipe cookbook for completeness. HelloWorld, Push-Quickstarts have been added as git submodule, to fetch them:

    $ git submodule init && git submodule update

## Building and installing each app

The demos utilize [cocoapods](http://cocoapods.org) for handling their dependencies. On the root directory of each demo, simply execute the following:

```bash
bundle install
bundle exec pod install
```

and then double click on the generated .xcworkspace to open in Xcode.


