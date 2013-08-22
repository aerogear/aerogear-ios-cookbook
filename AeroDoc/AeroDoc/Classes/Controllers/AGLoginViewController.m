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
#import "AeroDocAPIClient.h"
#import "AGDeviceRegistration.h"
#import "RNBlurModalView.h"

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


    UIImage *background = [UIImage imageNamed: @"aerogear_logo.png"];
    _illustration = [[UIImageView alloc] initWithImage:background];
    _illustration.center = CGPointMake(160, 120);
    [self.view addSubview: _illustration];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 160, 200, 32)];
    [label setLineBreakMode:UILineBreakModeWordWrap];
    [label setNumberOfLines:0];
    [label setTextColor:[UIColor blackColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setText:@"AeroDoc"];
    [label setFont:[UIFont boldSystemFontOfSize:20.0]];
    [[self view] addSubview:label];
    
    _username = [[UITextField alloc] initWithFrame:CGRectMake(55, 226, 200, 32)];
    _username.borderStyle = UITextBorderStyleRoundedRect;
    _username.placeholder = @"Username";
    _username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _username.autocorrectionType = UITextAutocorrectionTypeNo;
    _username.delegate = self;
    _username.backgroundColor = [UIColor clearColor];
    
    _password = [[UITextField alloc] initWithFrame:CGRectMake(55, 266, 200, 32)];
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
    _login.frame = CGRectMake(55, 310, 200, 52);
    _login.titleLabel.textColor = [UIColor blackColor];
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
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonImage forState:UIControlStateSelected];
    
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
    AeroDocAPIClient *apiClient = [AeroDocAPIClient sharedInstance];
    [apiClient loginWithUsername:_username.text password:_password.text success:^{
        // logged in successfully
        DLog(@"Sucessussfully logged");

        // a successful login means we can trigger the device registration
        // against the AeroGear UnifiedPush Server:
        [self deviceRegistration];
        [self initUINavigation];
    } failure:^(NSError *error) {
        ALog(@"An error has occured during login! \n%@", error);
    }];
}

//--------------------------------------------------------------------
// Device Registration for Unified Push Server
//--------------------------------------------------------------------

/**
 * Method is only invoked on a successful login on the user
 */
- (void) deviceRegistration {
#if !TARGET_IPHONE_SIMULATOR
    AGDeviceRegistration *registration = [[AGDeviceRegistration alloc] initWithServerURL:[NSURL URLWithString:URL_UNIFIED_PUSH]];
    
    [registration registerWithClientInfo:^(id<AGClientDeviceInformation> clientInfo) {
        [clientInfo setVariantID:VARIANT_ID];
        [clientInfo setVariantSecret:VARIANT_SECRET];
        
        // if the deviceToken value is nil, no registration will be performed
        // and the failure callback is being invoked!
        [clientInfo setDeviceToken:self.deviceToken];
        
        UIDevice *currentDevice = [UIDevice currentDevice];
        [clientInfo setAlias: [[AeroDocAPIClient sharedInstance] loginName]];
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
    leadsController.title = @"AeroGear AeroDoc";
    leadsController.tableView.rowHeight = 60;
    leadsController.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:leadsController];
    
    [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [navController.navigationBar setTintColor:[UIColor blackColor]];
  
    AGMyLeadsViewController *myLeadsController = [[AGMyLeadsViewController alloc] initWithStyle:UITableViewStylePlain];
    myLeadsController.title = @"AeroGear AeroDoc";
    myLeadsController.tableView.rowHeight = 60;
    myLeadsController.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    UINavigationController *myLeadsNavController = [[UINavigationController alloc] initWithRootViewController:myLeadsController];
    [myLeadsNavController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [myLeadsNavController.navigationBar setTintColor:[UIColor blackColor]];
    

    AGLocationViewController *locationViewController = [[AGLocationViewController alloc] init];
    locationViewController.title = @"AeroGear AeroDoc";
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:locationViewController];
    [settingsNavController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [settingsNavController.navigationBar setTintColor:[UIColor blackColor]];

    
    self.tabController = [[UITabBarController alloc] init];
    NSArray *controllers = [NSArray arrayWithObjects:navController, myLeadsNavController, settingsNavController, nil];
    self.tabController.viewControllers = controllers;
   
    UITabBar *tabBar = self.tabController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    //[tabBarItem1 setBadgeValue:@"2"];
    
    tabBarItem1.title = @"Available Leads";
    tabBarItem2.title = @"My Leads";
    tabBarItem3.title = @"Location";
    
    [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"aero_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"aero_greyed.png"]];
    [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"user_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"user_greyed.png"]];
    [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"pink_marker_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"pink_marker_greyed.png"]];
    
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
