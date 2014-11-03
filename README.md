# AeroGear iOS Differential Synchronization Demo
This project is a demo for the proof of concept work around [AeroGear Differential Synchronization](https://github.com/danbev/aerogear-sync-server/tree/differential-synchronization).

This demo uses the [iOS SyncClient](https://github.com/danbev/aerogear-ios-sync-client) which handles the communication with the sync server. 
The [iOS SyncEngine](https://github.com/danbev/aerogear-ios-sync) performs the actual work of the DiffSync protocol for the SyncClient, please refer to it's README.md for more details.

## Prerequisites 
This project requires Xcode 6.0 to run.

This project also uses a git submodule as a temporary solution until we can have Swift project in Cocoapods. The submodule need to be
initialized and updated:

    git submodule init
    git submodule update

Now, it is even worst that our submodule also contains a submodule (sorry):

    cd aerogear-ios-sync-client
    git submodule init
    git submodule update

    cd aerogear-ios-sync-client/aerogear-ios-sync/
    git submodule init
    git submodule update

    cd aerogear-ios-sync-client/aerogear-ios-sync/diffmatchpatch-ios
    git submodule init
    git submodule update

This project requires that the [AeroGear Differential Synchronization Server](https://github.com/danbev/aerogear-sync-server/tree/differential-synchronization/diffsync/server-netty)
be running. Please refer to that project for instructions for starting the server.

## Building

Building can be done by opening the project in Xcode:

    open AeroGearSyncDemo.xcodeproj

or you can use the command line:

    xcodebuild -project AeroGearSyncDemo.xcodeproj -scheme AeroGearSyncDemo -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO

## Running
The demo app can run from with in Xcode using Product->Run menu option (CMD+R).  


