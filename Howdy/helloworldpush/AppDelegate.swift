//
//  AppDelegate.swift
//  helloworldpush
//
//  Created by Corinne Krych on 09/09/15.
//  Copyright © 2015 AeroGear. All rights reserved.
//

import UIKit
import AeroGearPush
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Add some categories
        let textAction = UIMutableUserNotificationAction()
        textAction.identifier = "TEXT_ACTION"
        textAction.title = "Reply"
        textAction.isAuthenticationRequired = false
        textAction.isDestructive = false
        textAction.behavior = .textInput
        
        let declineAction = UIMutableUserNotificationAction()
        declineAction.identifier = "DECLINE_ACTION"
        declineAction.title = "Decline"
        declineAction.isAuthenticationRequired = false
        declineAction.isDestructive = true
        
        let category = UIMutableUserNotificationCategory()
        category.identifier = "CATEGORY_ID"
        category.setActions([textAction, declineAction], for: .default)
        category.setActions([textAction, declineAction], for: .minimal)
        
        let categories = NSSet(object: category) as! Set<UIUserNotificationCategory>
        
        // bootstrap the registration process by asking the user to 'Accept' and then register with APNS thereafter
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
    
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // time to register user with the "AeroGear UnifiedPush Server"
        let device = DeviceRegistration()
        // perform registration of this device
        device.register(clientInfo: { (clientInfo: ClientDeviceInformation!) in
            
            // set the deviceToken
            clientInfo.deviceToken = deviceToken
            
            // --optional config--
            // set some 'useful' hardware information params
            let currentDevice = UIDevice()
            
            clientInfo.operatingSystem = currentDevice.systemName
            clientInfo.osVersion = currentDevice.systemVersion
            clientInfo.deviceType = currentDevice.model
            },
            
            success: {
                // successfully registered!
                print("successfully registered with UPS!")
                
                // send NSNotification for success_registered, will be handle by registered AGViewController
                let notification = Notification(name:Notification.Name(rawValue: "success_registered"), object: nil)
                NotificationCenter.default.post(notification)
            },
            
            failure: {(error: NSError!) in
                print("Error Registering with UPS: \(error.localizedDescription)")
                
                let notification = Notification(name:Notification.Name(rawValue: "error_register"), object: nil)
                NotificationCenter.default.post(notification)
        })
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unified Push registration Error \(error)")
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

        print("UPS message received: \(userInfo)")
    }

}

