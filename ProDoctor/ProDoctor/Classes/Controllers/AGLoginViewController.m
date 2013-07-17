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

#import "AGConfig.h"
#import "AGLoginViewController.h"

#import "AGLeadsViewController.h"
#import "AGMyLeadsViewController.h"
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
@synthesize tabController = _tabController;

- (void)viewDidUnload {
    [super viewDidUnload];
    
    DLog(@"AGLoginViewController viewDidUnLoad");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"AGLoginViewController start viewDidLoad");
    self.view.backgroundColor = [UIColor clearColor];
    UIImage *logoBackground = [UIImage imageNamed: @"prodoctor.png"];
    _logo = [[UIImageView alloc] initWithImage:logoBackground];
    _logo.center = CGPointMake(160, 60);
    [self.view addSubview: _logo];

    UIImage *background = [UIImage imageNamed: @"aerogear_logo.png"];
    _illustration = [[UIImageView alloc] initWithImage:background];
    _illustration.center = CGPointMake(160, 360);
    [self.view addSubview: _illustration];

    
    _username = [[UITextField alloc] initWithFrame:CGRectMake(55, 160, 200, 32)];
    _username.borderStyle = UITextBorderStyleRoundedRect;
    _username.placeholder = @"Username";
    _username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _username.autocorrectionType = UITextAutocorrectionTypeNo;
    _username.delegate = self;
    _username.backgroundColor = [UIColor clearColor];
    
    _password = [[UITextField alloc] initWithFrame:CGRectMake(55, 206, 200, 32)];
    _password.borderStyle = UITextBorderStyleRoundedRect;
    _password.placeholder = @"Password";
    _password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _password.autocorrectionType = UITextAutocorrectionTypeNo;
    _password.secureTextEntry = YES;
    _password.delegate = self;
    _password.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_username];
    [self.view addSubview:_password];
    
    _login =  [self buttonWithText:@"Login"];
    _login.frame = CGRectMake(55, 256, 200, 52);
    _login.titleLabel.textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.0 alpha:1.0];
    [_login addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:_login];
    
    // load saved username/password
    [self load];
    
    DLog(@"AGLoginViewController end viewDidLoad");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(UIButton*) buttonWithText:(NSString*) text
{
    UIImage* buttonImage = [UIImage imageNamed:@"topAndBottomRow.png"];
    UIImage* buttonPressedImage = [UIImage imageNamed:@"topAndBottomRowSelected.png"];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonPressedImage forState:UIControlStateSelected];
    
    return button;
}

# pragma mark - Action Methods
//--------------------------------------------------------------------
// Login button action. Once successfully logged we register device
// for push notification
//--------------------------------------------------------------------
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
        [self deviceRegistration];
        [self initUINavigation];
    } failure:^(NSError *error) {
        ALog(@"An error has occured during login! \n%@", error);
    }];
}

//--------------------------------------------------------------------
// Device Registration for Unified Push Server
//--------------------------------------------------------------------
- (void) deviceRegistration {
#if !TARGET_IPHONE_SIMULATOR
    AGDeviceRegistration *registration = [[AGDeviceRegistration alloc] initWithServerURL:[NSURL URLWithString:URL_UNIFIED_PUSH]];
    
    [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
        [clientInfo setVariantID:VARIANT_ID];
        [clientInfo setDeviceToken:self.deviceToken];
        
        UIDevice *currentDevice = [UIDevice currentDevice];
        [clientInfo setAlias: [[ProDoctorAPIClient sharedInstance] loginName]];
        [clientInfo setOperatingSystem:[currentDevice systemName]];
        [clientInfo setOsVersion:[currentDevice systemVersion]];
        [clientInfo setDeviceType: [currentDevice model]];
        
    } success:^() {
        DLog(@"PushEE registration successful");
    } failure:^(NSError *error) {
        DLog(@"PushEE registration Error: %@", error);
    }];
#endif
}

//--------------------------------------------------------------------
// Create tabbarcontroller with two tabs:
// - Open Leads
// - My leads
// and navigation controller for UI flow
//--------------------------------------------------------------------
- (void) initUINavigation {
    AGLeadsViewController *leadsController = [[AGLeadsViewController alloc] init];
    leadsController.title = @"Leads";
    leadsController.tableView.rowHeight = 60;
    leadsController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:leadsController];
    
    UINavigationBar *navBar = [navController navigationBar];
    UIImage *backgroundImage = [UIImage imageNamed:@"topBarGreen.png"];
    [navBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    navController.toolbarHidden = YES;
    navController.navigationBarHidden = NO;
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [navController.navigationBar setTintColor:[UIColor brownColor]];
  
    AGMyLeadsViewController *myLeadsController = [[AGMyLeadsViewController alloc] initWithStyle:UITableViewStylePlain];
    myLeadsController.title = @"My leads";
    myLeadsController.tableView.rowHeight = 60;
    myLeadsController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tabController = [[UITabBarController alloc] init];
    NSArray *controllers = [NSArray arrayWithObjects:navController, myLeadsController, nil];
    self.tabController.viewControllers = controllers;
    
    [self presentViewController:self.tabController animated:YES completion:^{
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
