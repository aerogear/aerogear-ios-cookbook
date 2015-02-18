Jedi
====
Level: Beginner  
Technologies: Swift, iOS  
Summary: A basic example of [aerogear-ios-sync](https://github.com/aerogear/aerogear-ios-sync), [aerogear-ios-sync-client](https://github.com/aerogear/aerogear-ios-sync-client)  

What is it?
-----------
This project is a simple demo for the work around [AeroGear Differential Synchronization](https://github.com/aerogear/aerogear-sync-server).

This demo uses the [iOS SyncClient](https://github.com/aerogear/aerogear-ios-sync-client) which handles the communication with the sync server. 
The [iOS SyncEngine](https://github.com/aerogear/aerogear-ios-sync) performs the actual work of the DiffSync protocol for the SyncClient.

System requirements
-------------------
- iOS 8.X
- Xcode version 6.1.1

Configure
---------

This project requires that the [AeroGear Differential Synchronization Server](https://github.com/aerogear/aerogear-sync-server/tree/master/server/server-netty) be running. Please refer to that project for instructions for starting the server.

To run on actual device, go to ```Jedi/JsonPatchSync/AeroGearSyncDemo/Info.plist```, change the SyncServerHost to match your IP address and meke sure this is the same used on [AeroGear Differential Synchronization Server](https://github.com/aerogear/aerogear-sync-server/tree/master/server/server-netty).

    <key>SyncServerHost</key>
    <string>localhost</string>
    <key>SyncServerPort</key>
    <integer>7777</integer>

Build and Deploy Jedi
---------------------

### Run it in Xcode

The project uses utilizes [cocoapods](http://cocoapods.org) 0.36.0 pre-release for handling its dependencies. As a pre-requisite, install [cocoapods pre-release](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/) and then install the pod. On the root directory of the project run:

```bash
pod install
```

and then double click on the generated .xcworkspace to open in Xcode.

Application Flow
----------------

To test the application, you will need
Launch the application on your device
Launch the application on you simulator

![import](weather.png)

