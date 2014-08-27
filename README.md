# aerogear-aerodoc-ios [![Build Status](https://travis-ci.org/aerogear/aerogear-aerodoc-ios.png)](https://travis-ci.org/aerogear/aerogear-aerodoc-ios)

What's in aerogear-aerodoc-ios?
============================
AeroDoc is an tutorial application to demonstrate how to build an application using Unified Push server. To get the big picture:


![Unified Push Server big picture](https://github.com/aerogear/aerogear.org/blob/master/docs/unifiedpush/ups_userguide/img/aerogear_unified_push_server.png "Unified Push Server big picture")


You're a developper and you want to use AeroGear Unified Push Server to develop AeroDoc, a backend RESTful application with iOS client to create new leads and send them as push notifications to sale agents. 

If you want to know more about AeroDoc description, see [aerogear-aerodoc-backend](https://github.com/aerogear/aerogear-aerodoc-backend/blob/master/readme.md#description-of-the-application)

This repo focus on iOS client app. But before running the app, you'll need some setup. 

Prerequisites
=============
* This application is using Push notifications from APNS, it required setup of Provisioning Profile. 
Please follow the steps explained in [aerogear tutorial](http://aerogear.org/docs/unifiedpush/aerogear-push-ios/)

* Unified Push server should be deployed. Follow instructions from [aerogear unified push server](https://github.com/aerogear/aerogear-unifiedpush-server)

* AeroDoc backend should be deployed. Follow instructions from [AeroDoc backend](https://github.com/aerogear/aerogear-aerodoc-backend/blob/master/readme.md#deploying-the-app)

Setup
======
* [Login](http://aerogear.org/docs/unifiedpush/ups_userguide/admin-ui/#_login_and_landing_page) (reset password if needed) 

* [Register your application](http://aerogear.org/docs/unifiedpush/ups_userguide/admin-ui/#_create_and_manage_pushapplication) to get: 
 * your **pushApplicationID** 
 * and a **masterSecret** 

* [Register your iOS variant](http://aerogear.org/docs/unifiedpush/ups_userguide/admin-ui/#_create_and_manage_variants). Start with development one. You will need your apple provisionning as explained in prerequisites. You should get:
 * **variantID** 
 * and a **secret**

* [Setup AeroDoc backend configuration](https://github.com/aerogear/aerogear-aerodoc-backend/blob/master/readme.md#configure-the-push-server-details) AeroDoc backend needs to know:
  * where url is your Unified Push Server, it could be local or running on OpenShift.
  * what is your **pushApplicationID**
  * and **masterSecret**

* Setup AeroDoc iOS client
 * make sure bundle id of app matches the one in provisioning device
 * in [config file](https://github.com/aerogear/aerogear-aerodoc-ios/blob/master/AeroDoc/AeroDoc/Classes/Config/AGConfig.h), replace:

```c
  #define URL_AERODOC @"http://localhost:8080/aerodoc/"
  #define URL_UNIFIED_PUSH @"http://localhost:8080/ag-push/"
  #define VARIANT_ID @"YOUR_VARIANT"
  #define VARIANT_SECRET @"YOUR_SECRET"
  #define ENDPOINT @"rest"
```

you're all set, enjoy!

Installation
===========
 pod install

Working with the app
====================
Using AeroDoc, admin can create new leads, search for a nearby sale agent (SA), push the lead to a particular SA.

The SA logins to iOS AeroDoc aoo. Get a list of all open leads. Get a special message for the leads pushed to him. Puhsed leads appear with star icons. Once a lead is accepted, it is not available on open leads any more, but it is stored locally on SA device in MyLeads list. 

Post-install
============
Because the application is storing local data on device, you may want to clear data from time to time. 

