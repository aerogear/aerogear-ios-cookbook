aerogear-push-quickstart-ios
============================

See AeroDoc description in [aerogear-push-quickstart-backend](https://github.com/aerogear/aerogear-push-quickstart-backend/blob/master/readme.md#description-of-the-application)

Installation
===========
 pod install
 
Prerequisites
=============
* This application is using Push notifications from APNS, it required setup of Provisioning Profile. 
Please follow the steps explained in [aerogear tutorial](http://aerogear.org/docs/guides/aerogear-push-ios/)

* Unified Push server should be deployed. Follow instructions from [aerogear unified push server](https://github.com/aerogear/aerogear-unified-push-server)

* Register your application to get your app push id following instruction in [aerogear unified push server registration section](https://github.com/aerogear/aerogear-unified-push-server#register-push-app)

* Register your variant id as explained in [iOS variant section](https://github.com/aerogear/aerogear-unified-push-server#ios-variant)

* Before starting AeroDoc backend replace push-app-id as explained in [aerogear-push-quickstart-backend](https://github.com/aerogear/aerogear-push-quickstart-backend#setting-the-pushapplicationid-and-the-push-server-url)

* Before deploying your app on device:
- make sure bundle id of app matches the one in provisioning device
- replace server side url, app-push-id and variant id in [config file](https://github.com/aerogear/aerogear-push-quickstart-ios/blob/master/AeroDoc/AeroDoc/Classes/Config/AGConfig.h)

you're all set, enjoy!

Working with the app
====================
Using AeroDoc, admin can create new leads, search for a nearby sale agent (SA), push the lead to a particular SA.

The SA logins to iOS AeroDoc aoo. Get a list of all open leads. Get a special message for the leads pushed to him. Puhsed leads appear with star icons. Once a lead is accepted is not available on open leads any more but it is stored locally on SA device
in MyLeads list. 

Post-install
============
Because the application is storing local data on device, you may want to clear data from time to time. 

