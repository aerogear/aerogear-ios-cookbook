AeroGear iOS Cookbook
=====================

> Recipe apps built with Xcode9

The AeroGear iOS cookbook is a list of recipes to quick start your iOS AeroGear experience.

Each recipe is a complete iOS app. The goal of the recipes is to show you how easily you can use iOS AeroGear libraries and how it helps to achieve clean code. The app features are very lean and most of UI is kept to basics in order to focus on AeroGear library usage.

|                 | Project Info  |
| --------------- | ------------- |
| License:        | Apache License, Version 2.0  |
| Build:          | CocoaPods  |
| Documentation:  | https://aerogear.org/docs/guides/aerogear-ios-2.X/ |
| Issue tracker:  | https://issues.jboss.org/browse/AGIOS  |
| Mailing lists:  | [aerogear-users](http://aerogear-users.1116366.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-users))  |
|                 | [aerogear-dev](http://aerogear-dev.1069024.n5.nabble.com/) ([subscribe](https://lists.jboss.org/mailman/listinfo/aerogear-dev))  |


## Cookbook apps

| Recipe    | Core  | Push  | Security  | Platform  |
| ------------- |:-------------:| :-----:|:-----:|:----:|
| [Authentication](Authentication/README.md): login to [backend](https://github.com/aerogear/aerogear-backend-cookbook/tree/master/Authentication) using basic/digest auth.| - | - | **basic/digest** |iOS9, iOS10, iOS11|
| [ChuckNorrisJokes](ChuckNorrisJokes/README.md): Simple demo for http usage and serialization.| **http** | - | - |iOS9, iOS10, iOS11|
| [Shoot](Shoot/README.md): oauth2 sharing photo, web-app to display photos.| http, **oauth2** | - | - |iOS9, iOS10, iOS11|
| [SharedShoot](SharedShoot/README.md): login using OpenId Connect to download Shoot'nShare photos.| http, **oauth2** | - | - |iOS9, iOS10, iOS11|
| [Weather](Weather/README.md): geo-loation based app to fetch information using http lib.| **http** | - | - |iOS9, iOS10, iOS11|
| [UnifiedPushHelloWorld](UnifiedPushHelloWorld/README.md): Simple demo of Push registration and notification handles with framework as dependencies.| - | **push** | - |iOS9, iOS10, iOS11|
| [Two-Factor](Two-Factor/README.md): Demo OTP with Keycloak server.| - | **OTP** | - |iOS9, iOS10, iOS11|
| [Howdy](Howdy/README.md): Tell me how it is going for you. Howdy demoes text input notification with iOS9 on your phone and even on Watch.| - | **Push** | - |iOS9, iOS10, iOS11|

Most of the recipes illustrate one main topic which is listed in bold in the table. Some examples demonstrate other aspects of the libraries so it is also listed in the different topics.

Some of the demos uses a [backend](https://github.com/aerogear/aerogear-backend-cookbook/).

## Building and installing each app

The demos utilize [CocoaPods](http://cocoapods.org) for handling their dependencies. On the root directory of each demo, simply execute the following:

```bash
pod install
```

and then double click on the generated `.xcworkspace` to open in Xcode.

## Documentation

For more details about the current release, please consult [our documentation](https://aerogear.org/docs/guides/aerogear-ios-2.X/).

## Development

If you would like to help develop AeroGear you can join our [developer's mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-dev), join #aerogear on Freenode, or shout at us on Twitter @aerogears.

Also takes some time and skim the [contributor guide](http://aerogear.org/docs/guides/Contributing/)

## Questions?

Join our [user mailing list](https://lists.jboss.org/mailman/listinfo/aerogear-users) for any questions or help! We really hope you enjoy app development with AeroGear!

## Found a bug?

If you found a bug please create a ticket for us on [Jira](https://issues.jboss.org/browse/AGIOS) with some steps to reproduce it.
