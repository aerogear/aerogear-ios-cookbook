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

#import "AGViewController.h"
#import "ProDoctorAPIClient.h"

//#import "AGRegisterUserViewController.h"

//#import "AGToDoAPIService.h"

//#import "SVProgressHUD.h"

@implementation AGLoginViewController {
    UIImageView *_logo;
    UIImageView *_illustration;
    UITextField *_username;
    UITextField *_password;
    UIButton *_login;
}

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
    
    //[SVProgressHUD showWithStatus:@"Logging you in..." maskType:SVProgressHUDMaskTypeGradient];
    
    // first, we need to login to the service
    ProDoctorAPIClient *apiClient = [ProDoctorAPIClient sharedInstance];
    // Note: here we use static strings but a login screen
    // will provide the necessary authentication details.
    [apiClient loginWithUsername:_username.text password:_password.text success:^{
        
        // logged in successfully
        
        // time to retrieve remote data
        [[apiClient tasksPipe] read:^(id responseObject) {
            // update our model
            //_tasks = responseObject;
            
            // instruct table to refresh view
            //[self.tableView reloadData];
            
        } failure:^(NSError *error) {
            ALog(@"An error has occured during read! \n%@", error);
        }];
        
    } failure:^(NSError *error) {
        ALog(@"An error has occured during login! \n%@", error);
    }];
//    
//    [AGToDoAPIService initSharedInstanceWithBaseURL:TodoServiceBaseURLString username:_username.text password:_password.text success:^{
//        [SVProgressHUD dismiss];
//        AGTasksViewController *tasksController = [[AGTasksViewController alloc] initWithStyle:UITableViewStylePlain];
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tasksController];
//        navController.toolbarHidden = NO;
//        [navController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
//        [self presentModalViewController:navController animated:YES];
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
//                                                        message:[error localizedDescription]
//                                                       delegate:nil
//                                              cancelButtonTitle:@"Bummer"
//                                              otherButtonTitles:nil];
//        [alert show];
//        
//    }];
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
