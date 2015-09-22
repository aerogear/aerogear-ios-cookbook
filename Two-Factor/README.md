# Two-Factor
------------
Level: Beginner
Technologies: Swift, iOS
Summary: A basic example how to use OTP

## What is it?

The ```Two-Factor``` app demonstrates how to generate OTP tokens using Keycloak for the server side.

## How do I run it?

### 0. System Requirements

* iOS7
* Xcode 7 (Swift2.0 syntax)

### Configuring a testing server

1. Follow directions to install [OTP-Demo](https://github.com/aerogear/aerogear-backend-cookbook/blob/master/OTP-Demo/README.md)
1. Open OTP backend app [http://localhost:8080/otp-demo](http://localhost:8080/otp-demo)
1. Login with username: *user* and password: *password*.
1. Now open [iOS OTP client application](https://github.com/aerogear/aerogear-iOS-cookbook/tree/master/Two-Factor) on your phone
1. Then scan the *Scan QRCode*
1. Enter the current OTP on your mobile

For more details, please refer to our [documentation](http://aerogear.org/docs/specs/aerogear-security-otp/)

### Build Application

The project uses cocoapods 0.36+ release for handling its dependencies. As a pre-requisite, install cocoapods and then install the pod. On the root directory of the project run:

```
pod install
open TwoFactorOTP.xcworkspace
```
