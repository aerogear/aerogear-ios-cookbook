# aerogear-crypto-ios-demo [![Build Status](https://travis-ci.org/aerogear/aerogear-crypto-ios-demo.png)](https://travis-ci.org/aerogear/aerogear-crypto-ios-demo)

The demo ```AeroGear Crypto Password ``` is a single app that will let you easily create stronger passwords and store them in an encrypted database that only you can access. One central point for all your passwords. You can watch a video demonstrating the app [here](https://vimeo.com/78366502) 

Upon login, enter your password so that all of your existing data be decrypted. AeroGear Crypto Password secures your data using [AeroGear-Crypto library](https://github.com/aerogear/aerogear-crypto-ios) underneath powered by [NaCl](http://nacl.cr.yp.to/) library using powerful encryption [Curve 25519 algorithms](http://cr.yp.to/ecdh/curve25519-20060209.pdf).

## Getting started

The project requires [CocoaPods](http://cocoapods.org/) for dependency management;

_BEFORE_ you can run the application, you need to run the following command:

    pod install

Now you are almost done! You just need to open the ```AeroGear-Crypto-Demo.xcworkspace``` in order to run the app!

### Note
Once you run the application for the first time, you will need to set an initial password, which would be used in your subsequent logins.

Enjoy!