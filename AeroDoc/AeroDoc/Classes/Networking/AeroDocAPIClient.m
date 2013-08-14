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

#import "AeroDocAPIClient.h"
#import "AGLead.h"
#import "AGConfig.h"

@implementation AeroDocAPIClient

@synthesize leadsPipe = _leadsPipe;
@synthesize agentPipe = _agentPipe;

@synthesize userId = _userId;
@synthesize loginName = _loginName;
@synthesize location = _location;
@synthesize status = _status;

@synthesize localStore = _localStore;
@synthesize pushedLocalStore = _pushedLocalStore;

+ (AeroDocAPIClient *)sharedInstance {
    static AeroDocAPIClient *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(void (^)())success
                  failure:(void (^)(NSError *error))failure {

    NSURL *baseURL = [NSURL URLWithString:URL_AERODOC];

    // create the Pipeline object
    AGPipeline *pipeline = [AGPipeline pipelineWithBaseURL:baseURL];

    // create the Authenticator object
    AGAuthenticator *authenticator = [AGAuthenticator authenticator];

    // request the default 'AeroGear' authentication module from 'Authenticator'
    id<AGAuthenticationModule> authMod = [authenticator auth:^(id<AGAuthConfig> config) {
        [config setName:@"todoAuthMod"]; // assign it a name
        [config setBaseURL:baseURL]; // the base url to authenticate to
        [config setType:@"AG_SECURITY"]; // can be omitted as 'AG_SECURITY' is the default auth module
        [config setLoginEndpoint:[NSString stringWithFormat: @"%@/login", ENDPOINT]];
    }];
    
    // build the credentials JSON object for AeroDoc backend:
    NSDictionary *credentials = @{@"loginName": username, @"password": password};

    // login to the service
    [authMod login:credentials success:^(id object) {
        // if successfully logged in, it is time to construct our pipes.
        // Note that we assign the authentication module we
        // created earlier, so every request can be properly
        // authenticated against the remote endpoints.
        _userId = object[@"id"];
        _loginName = object[@"loginName"];
        _location = object[@"location"];
        _status = object[@"status"];
        
        _leadsPipe = [pipeline pipe:^(id<AGPipeConfig> config) {
            [config setName:@"leads"];
            [config setAuthModule:authMod];
            [config setEndpoint:[NSString stringWithFormat: @"%@/leads", ENDPOINT]];
            
        }];

        _agentPipe = [pipeline pipe:^(id<AGPipeConfig> config) {
            [config setName:@"saleagents"];
            [config setAuthModule:authMod];
            [config setEndpoint:[NSString stringWithFormat: @"%@/saleagents", ENDPOINT]];
            
        }];
        
        // initialize local store
        AGDataManager *dm = [AGDataManager manager];
        _localStore = [dm store:^(id<AGStoreConfig> config) {
            // each login has a different store associated
            [config setName:username];
            [config setType:@"PLIST"];
        }];
        _pushedLocalStore = [dm store:^(id<AGStoreConfig> config) {
            // each login has a different store associated
            [config setName:[NSString stringWithFormat: @"pusheLocalStorage%@", username]];
            [config setType:@"PLIST"];
        }];
        // inform client that we have successfully logged in
        success();

    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)fetchLeads:(void (^)(NSMutableArray *leads))success
           failure:(void (^)(NSError *error))failure {
    
    [_leadsPipe read:^(id responseObject) {
        NSMutableArray *leads = [NSMutableArray array];
        
        for (id leadDict in responseObject) {
            AGLead *lead = [[AGLead alloc] initWithDictionary:leadDict];
            
            [leads addObject:lead];
        }
        
        success(leads);
        
    } failure:^(NSError *error) {
        
        failure(error);
    }];
}


- (void)postLead:(AGLead *)lead
         success:(void (^)())success
         failure:(void (^)(NSError *error))failure {
    
    [_leadsPipe save:[lead dictionary] success:^(id responseObject) {
        if (lead.recId == nil) { // if it is a new lead, set the id
            lead.recId = [responseObject objectForKey:@"id"];
        }
        
        success();
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)changeStatus:(NSString*) status
             success:(void (^)())success
             failure:(void (^)(NSError *error))failure {
    
    [self changeAgentWithStatus:status location:_location success:success failure:failure];
}

- (void)changeLocation:(NSString*) location
               success:(void (^)())success
               failure:(void (^)(NSError *error))failure {
    
    [self changeAgentWithStatus:_status location:location success:success failure:failure];
}


- (void)changeAgentWithStatus:(NSString*)status
                     location:(NSString*)location
                      success:(void (^)())success
                      failure:(void (^)(NSError *error))failure {
    
    NSDictionary *params = @{@"id": _userId, @"loginName": _loginName,
                             @"status": status,
                             @"location": location};
    
    [_agentPipe save:params success:^(id responseObject) {
        // update local status on success
        _status = status;
        _location = location;
        
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

@end
