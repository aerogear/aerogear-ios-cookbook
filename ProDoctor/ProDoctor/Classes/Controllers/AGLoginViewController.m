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

#import "AGLoginViewController.h"

#import "AGLeadsViewController.h"
#import "ProDoctorAPIClient.h"
#import "AGDeviceRegistration.h"


@implementation AGLoginViewController {
    UIImageView *_logo;
    UIImageView *_illustration;
    UITextField *_username;
    UITextField *_password;
    UIButton *_login;
}

@synthesize deviceToken = _deviceToken;
@synthesize navController = _navController;

- (void)viewDidUnload {
    [super viewDidUnload];
    
    DLog(@"AGLoginViewController viewDidUnLoad");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"AGLoginViewController start viewDidLoad");
    self.view.backgroundColor = [UIColor whiteColor];
   
    UIImage *logoBackground = [UIImage imageNamed: @"prodoctor.png"];
    _logo = [[UIImageView alloc] initWithImage:logoBackground];
    _logo.center = CGPointMake(160, 60);
    [self.view addSubview: _logo];
    
    UIImage *background = [UIImage imageNamed: @"heart_tool.png"];
    _illustration = [[UIImageView alloc] initWithImage:background];
    _illustration.center = CGPointMake(180, 360);    
    [self.view addSubview: _illustration];

    
    _username = [[UITextField alloc] initWithFrame:CGRectMake(55, 120, 200, 32)];
    _username.borderStyle = UITextBorderStyleRoundedRect;
    _username.placeholder = @"Username";
    _username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _username.autocorrectionType = UITextAutocorrectionTypeNo;
    _username.delegate = self;
    
    
    _password = [[UITextField alloc] initWithFrame:CGRectMake(55, 166, 200, 32)];
    _password.borderStyle = UITextBorderStyleRoundedRect;
    _password.placeholder = @"Password";
    _password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _password.autocorrectionType = UITextAutocorrectionTypeNo;
    _password.secureTextEntry = YES;
    _password.delegate = self;
    
    [self.view addSubview:_username];
    [self.view addSubview:_password];
    
    _login = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _login.frame = CGRectMake(55, 216, 200, 32);
    [_login addTarget:self action:@selector(login:)
        forControlEvents:UIControlEventTouchDown];
    
    [_login setTitle:@"Login" forState:UIControlStateNormal];
    
    [self.view addSubview:_login];
    
    // load saved username/password
    [self load];
    
    DLog(@"AGLoginViewController end viewDidLoad");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

# pragma mark - Action Methods

- (IBAction)login:(id)sender {
    if (_username.text == nil || _password.text == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"Please enter your username and password!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Bummer"
                              
                                              otherButtonTitles:nil];

        [alert show];
        return;
    }
    
    // save username/passwd for future logins
    [self save];
    // first, we need to login to the service
    ProDoctorAPIClient *apiClient = [ProDoctorAPIClient sharedInstance];
    [apiClient loginWithUsername:_username.text password:_password.text success:^{
        
        // logged in successfully
        DLog(@"Sucessussfully logged");
        
        
        #if !TARGET_IPHONE_SIMULATOR
        //--------------------------------------------------------------------
        // Registration of actual device. 
        //--------------------------------------------------------------------
        AGDeviceRegistration *registration =
        
        [[AGDeviceRegistration alloc] initWithServerURL:[NSURL URLWithString:@"http://192.168.0.13:8080/ag-push/"]];
        
        // perform registration of this device
        [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
            // set up configuration parameters
            
            // You need to fill the ID you received when performing
            // the mobile variant registration with the server.
            // See section "Register an iOS Variant" in the guide:
            // http://aerogear.org/docs/guides/aerogear-push-ios/unified-push-server/
            [clientInfo setMobileVariantID:@"6f15c68f-9792-4cc6-b7c9-08206958dc15"];
            
            // apply the deviceToken as received by Apple's Push Notification service
            [clientInfo setDeviceToken:self.deviceToken];
            
            // --optional config--
            // set some 'useful' hardware information params
            UIDevice *currentDevice = [UIDevice currentDevice];
            [clientInfo setAlias: [[ProDoctorAPIClient sharedInstance] loginName]];
            [clientInfo setOperatingSystem:[currentDevice systemName]];
            [clientInfo setOsVersion:[currentDevice systemVersion]];
            [clientInfo setDeviceType: [currentDevice model]];
            
        } success:^() {
            
            // successfully registered!
            
        } failure:^(NSError *error) {
            // An error occurred during registration.
            // Let's log it for now
            NSLog(@"PushEE registration Error: %@", error);
        }];
        #endif        
        
        //--------------------------------------------------------------------
        // Move to Leads list
        //--------------------------------------------------------------------
        AGLeadsViewController *leadsController = [[AGLeadsViewController alloc] initWithStyle:UITableViewStylePlain];
        //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:leadsController];
        self.navController = [[UINavigationController alloc] initWithRootViewController:leadsController];
        self.navController.toolbarHidden = NO;
        [self.navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self presentModalViewController:self.navController animated:YES];
        
        
    } failure:^(NSError *error) {
        ALog(@"An error has occured during login! \n%@", error);
    }];
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


# pragma mark - load/save methods

- (void)load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [defaults objectForKey:@"username"];
    NSString *password = [defaults objectForKey:@"password"];
    
    _username.text = username;
    _password.text = password;
}

- (void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:_username.text forKey:@"username"];
    [defaults setObject:_password.text forKey:@"password"];
}

@end
