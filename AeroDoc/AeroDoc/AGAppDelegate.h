//
//  AGAppDelegate.h
//  AeroDoc
//
//  Created by Corinne Krych on 6/17/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//
//#import "AGLoginViewController.h"
#import <UIKit/UIKit.h>

@class AGLoginViewController;
@interface AGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) AGLoginViewController *viewController;
@end
