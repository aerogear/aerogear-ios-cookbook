//
//  AGAppDelegate.m
//  ProDoctor
//
//  Created by Corinne Krych on 6/17/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGLoginViewController.h"
#import "AGLeadsViewController.h"
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
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

#pragma mark - Push Notification handling

 // Here we need to register this "Mobile Variant Instance"
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
{
    [self.viewController setDeviceToken:deviceToken];
}

// There was an error with connecting to APNs or receiving an APNs generated token for this phone!
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // something went wrong, while talking to APNs
    // for now we simply log the error
    NSLog(@"APNs Error: %@", error);
}

// When the program is in the foreground, this callback receives the Payload of the received Push Notification message
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // TODO
    NSString *alertValue = userInfo[@"aps"][@"alert"];
    
    NSString *name = userInfo[@"name"];
    NSString *phone = userInfo[@"phone"];
    NSString *location = userInfo[@"location"];
    DLog(@"Lead pushed: name=%@ location=%@ phone=%@ ", name, location, phone);
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Custom Dialog, while Program is active"
                          message: @"Lead"
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    AGLeadsViewController *current = (AGLeadsViewController *)self.viewController.navController.visibleViewController;
    
    [current displayLeads];
    [alert show];;
}

@end
