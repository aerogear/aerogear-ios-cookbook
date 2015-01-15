# AeroGear iOS Differential Synchronization Demo
This project is a demo for the proof of concept work around [AeroGear Differential Synchronization](https://github.com/danbev/aerogear-sync-server/tree/differential-synchronization).

This demo uses the [iOS SyncClient](https://github.com/danbev/aerogear-ios-sync-client) which handles the communication with the sync server. 
The [iOS SyncEngine](https://github.com/danbev/aerogear-ios-sync) performs the actual work of the DiffSync protocol for the SyncClient, please refer to it's README.md for more details.

## Prerequisites 
This project requires Xcode 6.0 to run.

This project uses [CocoaPods](http://cocoapods.org/) to managed its dependencies. The following command 
must be run prior to building:
    
    sudo gem install cocoapods --pre
    pod install

This project is also a Cocoapod and can be pushed to the Cocoapods specs repository.
Currently we are using a private/local Cocoapods repo before publishing the real ones. This is only for testing. Please
follow the instructions [here](https://github.com/danbev/Cocoapods-repo) to set up a local repo.


This project requires that the [AeroGear Differential Synchronization Server](https://github.com/danbev/aerogear-sync-server/tree/differential-synchronization/diffsync/server-netty)
be running. Please refer to that project for instructions for starting the server.

## Building

Building can be done by opening the project in Xcode:

    open AeroGearSyncDemo.xcworkspace

or you can use the command line:

    xcodebuild -project AeroGearSyncDemo.xcworkspace -scheme AeroGearSyncDemo -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO

## Running
The demo app can run from with in Xcode using Product->Run menu option (CMD+R).  


