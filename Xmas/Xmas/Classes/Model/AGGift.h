//
//  AGGift.h
//  Xmas
//
//  Created by Corinne Krych on 11/19/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGGift : NSObject
@property(nonatomic, strong) NSString* recId;
@property(nonatomic, strong) NSString* toWhom;
@property(nonatomic, strong) NSString* description;
@property(nonatomic, strong) NSData* photo;
@end
