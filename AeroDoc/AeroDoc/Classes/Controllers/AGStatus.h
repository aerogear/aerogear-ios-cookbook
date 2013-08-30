//
//  AGStatusViewController.h
//  AeroDoc
//
//  Created by Corinne Krych on 8/29/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGStatus : NSObject
- (UIBarButtonItem*) registerStatusItemOnTarget:target;
- (UIBarButtonItem*) changeStatusOnTarget:target;
+ (AGStatus *)sharedInstance;
+ (NSMutableArray *)targetsList;
@end
