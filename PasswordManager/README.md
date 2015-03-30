PasswordManager
===============
Level: Beginner  
Technologies: ObjC, iOS  
Summary: A simple example to store password in an encrypted database.

What is it?
-----------

The demo ```AeroGear Crypto Password ``` is a single app that will let you easily create stronger passwords and store them in an encrypted database that only you can access. One central point for all your passwords. You can watch a video demonstrating the app [here](https://vimeo.com/78366502) 

Upon login, enter your password so that all of your existing data be decrypted. AeroGear Crypto Password secures your data using [AeroGear-Crypto library](https://github.com/aerogear/aerogear-crypto-ios) underneath powered by [NaCl](http://nacl.cr.yp.to/) library using powerful encryption [Curve 25519 algorithms](http://cr.yp.to/ecdh/curve25519-20060209.pdf).

NOTE:
Once you run the application for the first time, you will need to set an initial password, which would be used in your subsequent logins.

System requirements
-------------------
- iOS 7.X
- Xcode version 6.1.1 and later

Build and Deploy Two-Factor
---------------------------

The project uses [cocoapods](http://cocoapods.org). As a pre-requisite, install [cocoapods](http://blog.cocoapods.org/CocoaPods-0.36/) and then install the pod. On the root directory of the project run:

```bash
pod install
```

and then double click on the generated .xcworkspace to open in Xcode.