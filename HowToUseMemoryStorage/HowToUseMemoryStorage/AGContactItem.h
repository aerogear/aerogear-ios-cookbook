//
//  AGContactItem.h
//  HowToUseMemoryStorage
//
//  Created by Corinne Krych on 10/15/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AGContact

-(id)initWithName:(NSString*)name andPhoneNumber:(NSString*)phoneNumber;

@end

@interface AGContactItem : NSObject<AGContact>

@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* phoneNumber;

-(id)initWithName:(NSString*)name andPhoneNumber:(NSString*)phoneNumber;

@end


