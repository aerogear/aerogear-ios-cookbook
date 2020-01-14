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



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // bootstrap the registration process by asking the user to 'Accept' and then register with APNS thereafter
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
        })
        UIApplication.shared.registerForRemoteNotifications()
        
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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

}

