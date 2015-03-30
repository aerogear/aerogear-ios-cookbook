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

#import "AGOTPViewController.h"
#import "AGLoginViewControler.h"
#import "AGAppDelegate.h"

#import "AGOTPClient.h"
#import "SVProgressHUD.h"

#import "AGTotp.h"
#import "AGBase32.h"

@implementation AGOTPViewController {
    NSString *_secret;
    AGTotp *_totp;
    
    NSTimer *_updateTokenTimer;
    NSUInteger secs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD showWithStatus:@"Retrieving secret" maskType:SVProgressHUDMaskTypeGradient];
    
    secs = 30;
    self.status.text = @"";
    
    // retrieve secret
    [[AGOTPClient sharedInstance] fetchSecret:^(id responseObject) {
        [SVProgressHUD dismiss];
        
        //extract "secret"
        NSString *uri = [responseObject objectForKey:@"uri"];
        NSRange start = [uri rangeOfString:@"="];
        _secret = [uri substringFromIndex:start.location+1];
        
        // initialize OTP
        _totp = [[AGTotp alloc] initWithSecret:[AGBase32 base32Decode:_secret]];
        
        // generate token
        self.otp.text = [_totp generateOTP];
        
        [self startTimer];
        
    } failure:^(NSError *error) {
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
    NSDictionary *params = @{@"secret": self.otp.text};
    
    [SVProgressHUD showWithStatus:@"Validating OTP" maskType:SVProgressHUDMaskTypeGradient];
    
    
    [[AGOTPClient sharedInstance] verifyOTP:params success:^(id responseObject) {
        [SVProgressHUD dismiss];
        self.status.text =@"Success!";
        self.status.textColor = [UIColor greenColor];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        self.status.text =@"Failed!";
        self.status.textColor = [UIColor redColor];
        
        [self startTimer];
    }];
}

- (IBAction)logoutPressed:(id)sender {
    [SVProgressHUD show];
    
    [[AGOTPClient sharedInstance] logout:^{
        [SVProgressHUD dismiss];
        
        AGLoginViewControler *loginController = [[AGLoginViewControler alloc] initWithNibName: @"AGLoginViewControler" bundle:nil];
        AGAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        
        [delegate transitionToViewController:loginController withTransition:UIViewAnimationOptionTransitionFlipFromLeft];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        
        [self startTimer];
    }];
}

#pragma mark - Utility Methods

- (void) tick:(NSTimer *) timer {
    secs--;
    
    if (secs == 0) {
        self.otp.text = [_totp generateOTP];
        secs = 30;
    }
    
    self.timer.text = [NSString stringWithFormat:@"%ld", (long)secs];
}

- (void)startTimer {
    secs = 30;
    _updateTokenTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                         target:self
                                                       selector:@selector(tick:)
                                                       userInfo:nil
                                                        repeats:YES];
}

#pragma mark - UITextField delegate methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self.otp resignFirstResponder];
    return YES;
}

@end
