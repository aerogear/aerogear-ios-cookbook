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

#import "AGLead.h"

@implementation AGLead

@synthesize recId = _recId;
@synthesize name = _name;
@synthesize location = _location;
@synthesize phoneNumber = _phoneNumber;
@synthesize saleAgent = _saleAgent;
@synthesize isPushed = _isPushed;

- (id)init {
    if (self = [super init]) {          
    }
    
    return (self);
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.recId = [dictionary objectForKey:@"id"];
        self.name = [dictionary objectForKey:@"name"];
        self.location = [dictionary objectForKey:@"location"];
        self.phoneNumber = [dictionary objectForKey:@"phoneNumber"];
        self.saleAgent = [dictionary objectForKey:@"saleAgent"];
        self.isPushed =  @0;
    }
    
    return (self);
}

-(NSDictionary *)dictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (self.recId != nil)
        [dict setObject:[self.recId stringValue] forKey:@"id"];
    if (self.name != nil)
        [dict setObject:self.name forKey:@"name"];
    if (self.location != nil)
        [dict setObject:self.location forKey:@"location"];
    if (self.phoneNumber != nil)
        [dict setObject:self.phoneNumber forKey:@"phoneNumber"];
    if (self.saleAgent != nil)
        [dict setObject:self.saleAgent forKey:@"saleAgent"];
    if (self.isPushed != nil)
        [dict setObject:self.isPushed forKey:@"isPushed"];
    
    return dict;
}

- (void)copyFrom:(AGLead *)lead {
    self.recId = lead.recId;
    self.name = lead.name;
    self.location = lead.location;
    self.phoneNumber = lead.phoneNumber;
    self.saleAgent = lead.saleAgent;
    self.isPushed = lead.isPushed;
}

- (id)copyWithZone:(NSZone *)zone {
    AGLead *lead;
    
    lead = [[[self class] allocWithZone:zone] init];
    
    lead.recId = self.recId;
    lead.name = self.name;
    lead.location = self.location;
    lead.phoneNumber = self.phoneNumber;
    lead.saleAgent = self.saleAgent;
    self.isPushed = lead.isPushed;
    
    return lead;
}

- (BOOL)isEqual: (id)other {
    if (![other isKindOfClass:[AGLead class]])
        return NO;
    
    AGLead *otherLead = (AGLead *) other;
    
    return ([self.recId isEqualToNumber:otherLead.recId]);
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ [id=%@, name=%@, location=%@, phoneNumber=%@, saleAgent=%@]",
            self.class, self.recId, self.name, self.location, self.phoneNumber, self.saleAgent];
}

@end
