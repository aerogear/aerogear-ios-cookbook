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

#import "AGOTPClient.h"

#define AGControllerBaseURL @"http://controller-aerogear.rhcloud.com/"

@implementation AGOTPClient

+ (id)sharedInstance {
    static AGOTPClient *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[AGOTPClient alloc] initWithBaseURL:
                            [NSURL URLWithString:AGControllerBaseURL]];
    });
    
    return __sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        /*
        //custom settings
        [self setDefaultHeader:@"x-api-token" value:BeersAPIToken];
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
         */
    }
    
    return self;
}

@end