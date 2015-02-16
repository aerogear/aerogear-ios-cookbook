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

#import "AGStatus.h"
#import "AeroDocAPIClient.h"

@interface AGStatus ()

@end

@implementation AGStatus


+ (AGStatus *)sharedInstance {
    static AGStatus *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

+ (NSMutableArray *)targetsList {
    static NSMutableArray *_targets = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _targets = [[NSMutableArray alloc] init];
    });
    
    return _targets;
}

- (UIBarButtonItem*) registerStatusItemOnTarget:target {
    [[AGStatus targetsList] addObject:target];    
    return [self changeStatusOnTarget:target];
}


- (UIBarButtonItem*) changeStatusOnTarget:target {
    UIImage *statusImage;
    UIBarButtonItem *statusButton;
    if ([[AeroDocAPIClient sharedInstance].status isEqualToString:@"PTO"]) {
        statusImage = [UIImage imageNamed:@"orange.png"];
        
        statusButton = [[UIBarButtonItem alloc] initWithImage:statusImage landscapeImagePhone:statusImage
                                                        style:UIBarButtonItemStylePlain
                                                       target:target
                                                       action:@selector(changeStatus)];
        statusButton.tintColor = [UIColor orangeColor];
    } else {
        statusImage = [UIImage imageNamed:@"green.png"];
        
        
        statusButton = [[UIBarButtonItem alloc] initWithImage:statusImage landscapeImagePhone:statusImage
                                                        style:UIBarButtonItemStylePlain
                                                       target:target
                                                       action:@selector(changeStatus)];
        statusButton.tintColor = [UIColor greenColor];
        
    }
    
    
    return statusButton;
}
@end
