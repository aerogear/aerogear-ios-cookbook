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
#import <AeroGear/AeroGear.h>

static AGOTPClient *__sharedInstance;

@implementation AGOTPClient {
    id<AGPipe> _secretPipe;
    id<AGPipe> _otpPipe;

    id<AGAuthenticationModule> _authModule;
}

+ (void)initSharedInstanceWithBaseURL:(NSString *)baseURL
                             username:(NSString *)user
                             password:(NSString *)paswd
                              success:(void (^)())success
                              failure:(void (^)(NSError *error))failure {
    
    __sharedInstance = [[AGOTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]
                                                        username:user password:paswd
                                                         success:success failure:failure];
}

+ (id)sharedInstance {
    return __sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url
             username:(NSString *)user
             password:(NSString *)passwd
              success:(void (^)())success
              failure:(void (^)(NSError *error))failure {
    if (self) {

        AGAuthenticator* authenticator = [AGAuthenticator authenticator];
        
        _authModule = [authenticator auth:^(id<AGAuthConfig> config) {
            [config setName:@"otpAuthModule"];
            [config setBaseURL:url];
        }];

        [_authModule login:@{@"loginName": user, @"password": passwd} success:^(id object) {
            
            AGPipeline* pipeline = [AGPipeline pipelineWithBaseURL:url];
            
            // receive secret 'pipe' (usually the secret is not received via HTTP):
            _secretPipe = [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"Secret"];
                [config setEndpoint:@"auth/otp/secret"]; // to be appened to the baseURL...
                [config setAuthModule:_authModule];
            }];

            // the verify OTP pipe:
            _otpPipe = [pipeline pipe:^(id<AGPipeConfig> config) {
                [config setName:@"otp"];
                [config setEndpoint:@"auth/otp"]; // to be appened to the baseURL...
                [config setAuthModule:_authModule];
            }];

            if (success) {
                success();
            }
            
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }
    
    return self;
}

- (void) logout:(void (^)())success
        failure:(void (^)(NSError *error))failure {
    [_authModule logout:success failure:failure];
}

- (void)fetchSecret:(void (^)(id responseObject))success
            failure:(void (^)(NSError *error))failure {
    
    [_secretPipe read:^(id responseObject) {
        
        NSDictionary *otpJSON;
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
            otpJSON = [responseObject objectAtIndex:0]; // extract the only/first entry
        } else {
            otpJSON = responseObject; // must be a dictionary
        }

        success(otpJSON);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (void)verifyOTP:(NSDictionary *)secret success:(void (^)(id responseObject))success
          failure:(void (^)(NSError *error))failure {

    [_otpPipe save:secret success:^(id responseObject) {
        success(responseObject);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

@end