//
//  ExtensionDelegate.swift
//  helloworldpush WatchKit Extension
//
//  Created by Corinne Krych on 09/09/15.
//  Copyright © 2015 AeroGear. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        print("applicationDidFinishLaunching")
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
        print("applicationWillResignActive")
    }
    func handleAction(withIdentifier: String?, forRemoteNotification remoteNotification: [AnyHashable: Any]) // when the app is launched from a notification. If launched from app icon in notification UI, identifier will be empty
    {
        // This is the callback when the user has clicked on one of the action
        // Once you retrived the text, do something usefull with it!
        print("After selection an action \(withIdentifier)!!!")
    }

}
