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
    
    // set background
    UIView *backgroundView = [[UIView alloc] initWithFrame: self.window.frame];
    backgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    [self.window addSubview:backgroundView];
    
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

#pragma mark - Push Notification handling

 // Here we need to register this "Mobile Variant Instance"
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    // this delegate is invoked in a case of a successful registration with the APNs servers. The 'deviceToken'
    // argument passed into the function is used to identify this iOS device within APNs.

    // For simple applications it is reasonable to 'store' the deviceToken with a 3rd party server, like the
    // AeroGear UnifiedPush Server.

    // However since this application requires a logged-in user, we simply stash the deviceToken on the
    // AGLoginViewController. After a successful login the deviceToken is used to register this device against
    // the AeroGear UnifiedPush Server.
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

    NSString *recId = userInfo[@"id"];
    NSString *name = userInfo[@"name"];
    NSString *phone = userInfo[@"phone"];
    NSString *location = userInfo[@"location"];
    NSString *messageType = userInfo[@"messageType"];

    if ([messageType isEqual:@"accepted_lead"]) {
        // send to interest parties
        NSNotification *notification = [NSNotification notificationWithName:@"LeadAcceptedNotification"
                                                                     object:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        DLog(@"Lead accepted: id=%@ name=%@ location=%@ phone=%@ messageType=%@", recId, name, location, phone, messageType);

    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @""
                              message: [NSString stringWithFormat: @"Lead %@ is available!", name]
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        // send to interest parties
        NSNotification *notification = [NSNotification notificationWithName:@"LeadAddedNotification"
                                                                     object:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        DLog(@"Lead pushed: id=%@ name=%@ location=%@ phone=%@ messageType=%@", recId, name, location, phone, messageType);
    }
}

@end
