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
    
    [SVProgressHUD showWithStatus:@"Logging in" maskType:SVProgressHUDMaskTypeGradient];


    [AGOTPClient initSharedInstanceWithBaseURL:@"https://jaxrs-aerogear.rhcloud.com/aerogear-jaxrs-demo/rest/" username:self.username.text password:self.password.text success:^{
        [SVProgressHUD dismiss];
        
        AGOTPViewController *otpController = [[AGOTPViewController alloc] initWithNibName:@"AGOTPViewController" bundle:nil];
        AGAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        
        [delegate transitionToViewController:otpController withTransition:UIViewAnimationOptionTransitionFlipFromRight];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}
@end
