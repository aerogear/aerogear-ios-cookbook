//
//  AGGift.m
//  Xmas
//
//  Created by Corinne Krych on 11/19/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGGift.h"

@implementation AGGift
@synthesize recId;
@synthesize toWhom;
@synthesize description;
@synthesize photo;

-(id)initWithToWhom:(NSString*)friend andDescription:(NSString*)giftDescription {
    self = [super init];
    if (self) {
        toWhom = friend;
        description = giftDescription;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.recId = [dictionary objectForKey:@"id"];
        self.toWhom = [dictionary objectForKey:@"toWhom"];
        self.description = [dictionary objectForKey:@"description"];
    }
    
    return (self);
}

-(NSMutableDictionary *)dictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.recId != nil)
        [dict setObject:self.recId forKey:@"id"];
    [dict setObject:self.description forKey:@"description"];
    [dict setObject:self.toWhom forKey:@"toWhom"];
    
    return dict;
}

@end
