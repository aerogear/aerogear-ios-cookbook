/*
* JBoss, Home of Professional Open Source.
* Copyright Red Hat, Inc., and individual contributors
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit
import AeroGearPush

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // bootstrap the registration process by asking the user to 'Accept' and then register with APNS thereafter
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
        
        // Send metrics when app is launched due to push notification
        PushAnalytics.sendMetricsWhenAppLaunched(launchOptions: launchOptions)
        
        // Display all push messages (even the message used to open the app)
        if let options = launchOptions {
            if let option = options[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: Any] {
                let defaults: UserDefaults = UserDefaults.standard;
                // Send a message received signal to display the notification in the table.
                if let aps = option["aps"] as? [String: Any] {
                    if let alert = aps["alert"] as? String {
                        defaults.set(alert, forKey: "message_received")
                        defaults.synchronize()
                    } else {
                        if let alert = aps["alert"] as? [String: Any] {
                            let msg = alert["body"]
                            defaults.set(msg, forKey: "message_received")
                            defaults.synchronize()
                        }
                    }
                }
            }
        }
        
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // time to register user with the "AeroGear UnifiedPush Server"
        let device = DeviceRegistration(config: "pushconfig")
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
                
                // send Notification for success_registered, will be handle by registered ViewController
                let notification = Notification(name: Notification.Name(rawValue: "success_registered"), object: nil)
                NotificationCenter.default.post(notification as Notification)
            },
            
            failure: {(error: Error!) in
                print("Error Registering with UPS: \(error.localizedDescription)")
                
                let notification = Notification(name: Notification.Name(rawValue: "error_register"), object: nil)
                NotificationCenter.default.post(notification as Notification)
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        let notification:Notification = Notification(name:Notification.Name(rawValue: "error_register"), object:nil, userInfo:nil)
        NotificationCenter.default.post(notification)
        print("Unified Push registration Error \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // When a message is received, send Notification, would be handled by registered ViewController
        let notification:Notification = Notification(name: Notification.Name(rawValue: "message_received"), object:nil, userInfo:userInfo)
        NotificationCenter.default.post(notification)
        print("UPS message received: \(userInfo)")
        
        // Send metrics when app is launched due to push notification
        PushAnalytics.sendMetricsWhenAppAwoken(applicationState: application.applicationState, userInfo: userInfo)
        
        // No additioanl data to fetch
        fetchCompletionHandler(UIBackgroundFetchResult.noData)
    }
    
    // Needed on iOS 10 only, you won't be able to receive push messages when the app is in background due to a bug (https://forums.developer.apple.com/thread/54322) if you don't add this func.
    // It has been fixed on iOS 10.1
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        // When a message is received, send Notification, would be handled by registered ViewController
        let notification:Notification = Notification(name: Notification.Name(rawValue: "message_received"), object:nil, userInfo:userInfo)
        NotificationCenter.default.post(notification)
        print("UPS message received: \(userInfo)")
        
        // Send metrics when app is launched due to push notification
        PushAnalytics.sendMetricsWhenAppAwoken(applicationState: application.applicationState, userInfo: userInfo)
    }
    
}
