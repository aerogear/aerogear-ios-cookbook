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

#import "AGPasswordViewController.h"
#import "AGCredential.h"

#import <SVProgressHUD.h>

@interface AGPasswordViewController ()

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *password;

@end

@implementation AGPasswordViewController {
    BOOL _displayPass;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.name.text = self.credential.name;
    self.username.text = self.credential.username;

    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    DLog(@"AGPasswordViewController viewDidUnLoad");
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    DLog(@"AGPasswordViewController viewDidUnLoad");
}

#pragma mark - Action Methods
- (IBAction)handleGesture:(id)sender {
   _displayPass = !_displayPass;
    self.password.text = _displayPass? self.credential.password: @"************";
}

- (IBAction)clipboardCopy:(id)sender {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    pb.string = self.credential.password;
 
    [SVProgressHUD showSuccessWithStatus:@"Copied to clipboard!"];
}

#pragma mark UIAppplicationBackground notification

-(void)appWillResignActive:(NSNotification*)note {
    [self performSegueWithIdentifier:@"logout" sender:self];
}

@end
