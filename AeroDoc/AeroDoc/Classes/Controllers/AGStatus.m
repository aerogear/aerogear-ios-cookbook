//
//  AGStatusViewController.m
//  AeroDoc
//
//  Created by Corinne Krych on 8/29/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGStatus.h"
#import "AeroDocAPIClient.h"

@interface AGStatus ()

@end

@implementation AGStatus


+ (AGStatus *)sharedInstance {
    static AGStatus *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

+ (NSMutableArray *)targetsList {
    static NSMutableArray *_targets = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _targets = [[NSMutableArray alloc] init];
    });
    
    return _targets;
}

- (UIBarButtonItem*) registerStatusItemOnTarget:target {
    [[AGStatus targetsList] addObject:target];    
    return [self changeStatusOnTarget:target];
}


- (UIBarButtonItem*) changeStatusOnTarget:target {
    UIImage *statusImage;
    
    if ([[AeroDocAPIClient sharedInstance].status isEqualToString:@"PTO"]) {
        statusImage = [UIImage imageNamed:@"orange.png"];
    } else {
        statusImage = [UIImage imageNamed:@"green.png"];
    }
    
    UIBarButtonItem *statusButton = [[UIBarButtonItem alloc] initWithImage:statusImage landscapeImagePhone:statusImage
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:target
                                                                    action:@selector(changeStatus)];
    
    return statusButton;
}
@end
