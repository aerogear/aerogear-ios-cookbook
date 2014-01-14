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

#import "AeroGear.h"

@class AGLead;

@interface AeroDocAPIClient : NSObject

@property(readonly, nonatomic) id<AGPipe> leadsPipe;
@property(readonly, nonatomic) id<AGPipe> agentPipe;

@property(readonly, nonatomic) id<AGStore> localStore;
@property(readonly, nonatomic) id<AGStore> pushedLocalStore;

@property(readonly, nonatomic) NSNumber *userId;
@property(readonly, nonatomic) NSString *loginName;
@property(readonly, nonatomic) NSString *status;
@property(readonly, nonatomic) NSString *latitude;
@property(readonly, nonatomic) NSString *longitude;

+ (AeroDocAPIClient *)sharedInstance;

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(void (^)())success
                  failure:(void (^)(NSError *error))failure;

- (void)fetchLeads:(void (^)(NSMutableArray *leads))success
           failure:(void (^)(NSError *error))failure;

- (void)postLead:(AGLead *)lead
         success:(void (^)())success
         failure:(void (^)(NSError *error))failure;

- (void)changeStatus:(NSString*) status
             success:(void (^)())success
             failure:(void (^)(NSError *error))failure;

- (void)changeLocationWithLatitude:(NSString *)latitude
                         longitude:(NSString *)longitude
                           success:(void (^)())success
                           failure:(void (^)(NSError *error))failure;

@end
