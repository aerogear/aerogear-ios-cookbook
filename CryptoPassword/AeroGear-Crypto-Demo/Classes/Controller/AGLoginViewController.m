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
#import "AGPasswordManagerViewController.h"

#import <AeroGear/AeroGear.h>
#import <AGRandomGenerator.h>

#import <UIAlertView+Blocks.h>

// the salt
static NSString *const kSalt = @"salt";

@interface AGLoginViewController()

@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *login;

@end

@implementation AGLoginViewController {
    id<AGStore> store;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // popup a small alert to give a small description for the user to create
    // the initial password when the app is launced for the first time
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL launched = [defaults boolForKey:@"isLaunched"];
    if (!launched) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome!"
                                                        message:@"Since its the first time you are launching the app, please enter a new password to use"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        // update
        [defaults setBool:YES forKey:@"isLaunched"];
        // set a default salt which will be used for encrypt/decrypt
        [defaults setObject:[AGRandomGenerator randomBytes] forKey:kSalt];
        [defaults synchronize];
    }
    
    DLog(@"AGLoginViewController viewDidLoad");
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    DLog(@"AGLoginViewController viewDidUnLoad");
}

#pragma mark - Action Methods

-(IBAction)reset:(UIStoryboardSegue *)segue {
    // reset pass entry upon return
    self.password.text = @"";
}

- (IBAction)login:(id)sender {
    if ([self.password.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"Password is required!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    // set up crypto params configuration object
    AGPassphraseCryptoConfig *config = [[AGPassphraseCryptoConfig alloc] init];
    [config setSalt:[[NSUserDefaults standardUserDefaults] objectForKey:kSalt]];
    [config setPassphrase:self.password.text];

    // initialize the encryption service passing the config
    id<AGEncryptionService> encService = [[AGKeyManager manager] keyService:config];
    
    // access Store Manager
    AGDataManager *manager = [AGDataManager manager];

    // create store
    store = [manager store:^(id<AGStoreConfig> config) {
        [config setName:@"MyCredentialsStorage"];
        // can also be set to "ENCRYPTED_SQLITE" for the encrypted sqlite variant
        [config setType:@"ENCRYPTED_PLIST"];
        [config setEncryptionService:encService];
    }];
    
    // ok time to attempt reading..
    // if the store returns 'nil' upon first read, then there
    // was an error in the decryption of data, that is wrong
    // passphrase entered from the user
    if (![store readAll]) {
        [UIAlertView showWithTitle:@"Login failed!"
                           message:@"invalid credentials!"
                 cancelButtonTitle:@"Bummer"
                 otherButtonTitles:nil
                          tapBlock:nil];

        // can't do much
        return;
    }

    [self performSegueWithIdentifier:@"ValidationSucceeded" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AGPasswordManagerViewController *manager = [[segue.destinationViewController viewControllers] objectAtIndex:0];
    // set the store that the password manager will use
    manager.store = store;
 }

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
