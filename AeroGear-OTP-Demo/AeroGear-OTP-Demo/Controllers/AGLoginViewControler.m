/*
 * JBoss, Home of Professional Open Source.
 * Copyright 2012 Red Hat, Inc., and individual contributors
 * as indicated by the @author tags.
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

#import "AGLoginViewControler.h"

#import "AGOTPViewController.h"
#import "AGAppDelegate.h"

#import "AGOTPClient.h"
#import "SVProgressHUD.h"

@implementation AGLoginViewControler

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setUsername:nil];
    [self setPassword:nil];
    [super viewDidUnload];
}

- (IBAction)buttonPressed:(id)sender {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.username.text, @"aeroGearUser.id",
                            self.password.text, @"aeroGearUser.password",
                            nil];
    
    [SVProgressHUD showWithStatus:@"Logging in"];
    

    [[AGOTPClient sharedInstance] postPath:@"aerogear-controller-demo/login" parameters:params
      success:^(AFHTTPRequestOperation *operation, id response) {
          [SVProgressHUD dismiss];

          AGOTPViewController *otpController = [[AGOTPViewController alloc] initWithNibName:@"AGOTPViewController" bundle:nil];
          AGAppDelegate *delegate = [UIApplication sharedApplication].delegate;
          
          [delegate transitionToViewController:otpController withTransition:UIViewAnimationOptionTransitionFlipFromRight];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"\n%@\n", error);
        [SVProgressHUD dismiss];
    }];
}

@end
