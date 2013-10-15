//
//  AGContactItem.m
//  HowToUseMemoryStorage
//
//  Created by Corinne Krych on 10/15/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGContactItem.h"

@implementation AGContactItem
@synthesize name = _name;
@synthesize phoneNumber = _phoneNumber;

-(id)initWithName:(NSString*)name andPhoneNumber:(NSString*)phoneNumber {
    self = [super init];
    if (self) {
        _name = name;
        _phoneNumber = phoneNumber;
    }
    return self;
}

@end
