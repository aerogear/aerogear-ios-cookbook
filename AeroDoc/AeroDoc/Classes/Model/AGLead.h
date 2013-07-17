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

#import <Foundation/Foundation.h>

@interface AGLead : NSObject <NSCopying>

@property(strong, nonatomic) NSNumber *recId;
@property(copy, nonatomic) NSString *name;
@property(copy, nonatomic) NSString *location;
@property(copy, nonatomic) NSString *phoneNumber;
@property(copy, nonatomic) NSNumber *saleAgent;
@property(copy, nonatomic) NSNumber *isPushed;
// convert from JSON
- (id)initWithDictionary:(NSDictionary *)dictionary;
// convert to JSON
- (NSDictionary *)dictionary;

- (void)copyFrom:(AGLead *)lead;
@end
