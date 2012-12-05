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

#import "AGOTPViewController.h"
#import "AGLoginViewControler.h"
#import "AGAppDelegate.h"

#import "AGOTPClient.h"
#import "SVProgressHUD.h"

#import "AGTotp.h"

@implementation AGOTPViewController {
    NSString *_secret;
    AGTotp *_totp;
    
    NSTimer *_updateTokenTimer;
    NSUInteger secs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD showWithStatus:@"Retrieving secret"];
    
    secs = 30;
    self.status.text = @"";
    
    // retrieve secret
    [[AGOTPClient sharedInstance] registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [[AGOTPClient sharedInstance] getPath:@"aerogear-controller-demo/auth/otp/secret" parameters:nil
                                   success:^(AFHTTPRequestOperation *operation, id response) {
                                       [SVProgressHUD dismiss];
                                       
                                       //extract "secret"
                                       NSString *uri = [response objectForKey:@"uri"];
                                       NSRange start = [uri rangeOfString:@"="];
                                       _secret = [uri substringFromIndex:start.location+1];
                                       NSLog(@"%@", _secret);
                                       // initialize OTP
                                       _totp = [[AGTotp alloc] initWithSecret:[_secret dataUsingEncoding:NSASCIIStringEncoding]];
                                       // generate token
                                       self.otp.text = [_totp now:[NSDate date]];

                                       [self startTimer];
                                       
                                       [[AGOTPClient sharedInstance] unregisterHTTPOperationClass:[AFJSONRequestOperation class]];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [SVProgressHUD dismiss];
                                   }];
}

- (void)viewDidUnload {
    [self setOtp:nil];
    [self setTimer:nil];
    [self setStatus:nil];
    [super viewDidUnload];
}

# pragma mark - Action Methods

- (IBAction)checkPressed:(id)sender {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.otp.text, @"aeroGearUser.otp",
                            nil];
    
    [SVProgressHUD showWithStatus:@"Validating OTP"];
    
    [[AGOTPClient sharedInstance] postPath:@"aerogear-controller-demo/otp" parameters:params
                                   success:^(AFHTTPRequestOperation *operation, id response) {
                                       [SVProgressHUD dismiss];

                                       NSString *text = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                       
                                       NSLog(@"%@", text);

                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [SVProgressHUD dismiss];
                                       
                                       [self startTimer];                                       
                                   }];
}

- (IBAction)logoutPressed:(id)sender {
    [SVProgressHUD show];
    
    [[AGOTPClient sharedInstance] getPath:@"aerogear-controller-demo/logout" parameters:nil
                                   success:^(AFHTTPRequestOperation *operation, id response) {
                                       [SVProgressHUD dismiss];
                                       
                                       AGLoginViewControler *loginController = [[AGLoginViewControler alloc] initWithNibName: @"AGLoginViewControler" bundle:nil];
                                       AGAppDelegate *delegate = [UIApplication sharedApplication].delegate;
                                       
                                       [delegate transitionToViewController:loginController withTransition:UIViewAnimationOptionTransitionFlipFromLeft];
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       [SVProgressHUD dismiss];
                                       
                                       [self startTimer];
                                   }];
}

#pragma mark - Utility Methods

- (void) tick:(NSTimer *) timer {
    secs--;
    
    if (secs == 0) {
        self.otp.text = [_totp now:[NSDate date]];
        secs = 30;
    }
    
    self.timer.text = [NSString stringWithFormat:@"%d", secs];
}

- (void)startTimer {
    secs = 30;
    _updateTokenTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                         target:self
                                                       selector:@selector(tick:)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)stopTimer {
    if (_timer == nil)
        return;
    
    self.timer.text = @"";
    
    [_updateTokenTimer invalidate];
}

@end
