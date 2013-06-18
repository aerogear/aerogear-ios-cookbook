//
//  AGAppDelegate.m
//  ProDoctor
//
//  Created by Corinne Krych on 6/17/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGLoginViewController.h"
#import "AGAppDelegate.h"

#import "AeroGearPush.h"

@implementation AGAppDelegate

@synthesize window = _window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    self.viewController = [[AGLoginViewController alloc] init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

#pragma mark - Push Notification handling
//
// // Here we need to register this "Mobile Variant Instance"
//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
//{
//    // initialize "Registration helper" object using the
//    // base URL where the "AeroGear Unified Push Server" is running.
//    AGDeviceRegistration *registration =
//    
//        [[AGDeviceRegistration alloc] initWithServerURL:[NSURL URLWithString:@"<# URL of the running AeroGear UnifiedPush Server #>"]];
//    
//    // perform registration of this device
//    [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
//        // set up configuration parameters
//
//        // You need to fill the ID you received when performing
//        // the mobile variant registration with the server.
//        // See section "Register an iOS Variant" in the guide:
//        // http://aerogear.org/docs/guides/aerogear-push-ios/unified-push-server/
//        [clientInfo setMobileVariantID:@"<# Mobile Variant Id #>"];
//        
//        // apply the deviceToken as received by Apple's Push Notification service
//        [clientInfo setDeviceToken:deviceToken];
//
//        // --optional config--
//        // set some 'useful' hardware information params
//        UIDevice *currentDevice = [UIDevice currentDevice];
//        
//        [clientInfo setOperatingSystem:[currentDevice systemName]];
//        [clientInfo setOsVersion:[currentDevice systemVersion]];
//        [clientInfo setDeviceType: [currentDevice model]];
//
//    } success:^() {
//        
//        // successfully registered!
//
//    } failure:^(NSError *error) {
//        // An error occurred during registration.
//        // Let's log it for now
//        NSLog(@"PushEE registration Error: %@", error);
//    }];
//}
//
//// There was an error with connecting to APNs or receiving an APNs generated token for this phone!
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    // something went wrong, while talking to APNs
//    // for now we simply log the error
//    NSLog(@"APNs Error: %@", error);
//}
//
//// When the program is in the foreground, this callback receives the Payload of the received Push Notification message
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    // 'userInfo' contains information related to the remote notification.
//    // For demo reasons, we simply read the "alert" key, from the "aps" dictionary
//    NSString *alertValue = [userInfo valueForKeyPath:@"aps.alert"];
//    
//    UIAlertView *alert = [[UIAlertView alloc]
//                          initWithTitle: @"Custom Dialog, while Program is active"
//                          message: alertValue
//                          delegate: nil
//                          cancelButtonTitle:@"OK"
//                          otherButtonTitles:nil];
//    [alert show];
//}

@end
