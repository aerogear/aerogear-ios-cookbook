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

#import "AGPasswordManagerViewController.h"
#import "AGPasswordViewController.h"
#import "AGCredential.h"

#import <UIActionSheet+Blocks.h>

@implementation AGPasswordManagerViewController {
    NSMutableArray *_credentials;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _credentials = [[NSMutableArray alloc] init];
    
    // grab a snapshot of the store
    for (id obj in [self.store readAll]) {
        AGCredential *credential = [[AGCredential alloc] initFromDictionary:obj];
        [_credentials addObject:credential];
    }
    
     [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    DLog(@"AGPasswordManagerViewController viewDidLoad");
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _credentials = nil;
    
    DLog(@"AGPasswordManagerViewController viewDidUnLoad");
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_credentials count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    AGCredential *credential = [_credentials objectAtIndex:[indexPath row]];
    cell.textLabel.text = credential.name;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [UIActionSheet presentOnView:self.view
                           withTitle:@"Are you sure you want to delete this entry?"
                        cancelButton:@"Cancel"
                   destructiveButton:@"Yes" otherButtons:nil
                            onCancel:nil
                       onDestructive:^(UIActionSheet *actionSheet) {
                           
                           AGCredential *credential = [_credentials objectAtIndex:indexPath.row];
                           
                           NSError *error;
                           [self.store remove:[credential dictionary] error:&error];

                           if (error) {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Operation Failed!"
                                                                               message:error.localizedDescription
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"Bummer"
                                                                     otherButtonTitles:nil];
                               [alert show];
                               return;
                           }
                           
                           // update our local copy
                           [_credentials removeObjectAtIndex:indexPath.row];
                           
                           // ok, time to remove from the list
                           [tableView deleteRowsAtIndexPaths:@[indexPath]
                                            withRowAnimation:UITableViewRowAnimationFade];

                       } onClickedButton:nil
        ];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // prior to transition, assign delegates to
    // self so we can get notified
    
	if ([segue.identifier isEqualToString:@"AddPassword"]) {  // Add Screen
        UINavigationController *navigationController = segue.destinationViewController;
        AGAddPasswordViewController *addPasswordViewController = [[navigationController viewControllers] objectAtIndex:0];
		addPasswordViewController.delegate = self;

	} else if ([segue.identifier isEqualToString:@"ViewPassword"]) { // Details Screen
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
		AGPasswordViewController *passwordViewController = segue.destinationViewController;
        passwordViewController.credential = [_credentials objectAtIndex:indexPath.row];
    }
}

#pragma mark - AGAddPasswordViewController Delegate Methods

- (void)addPasswordViewControllerDidCancel:(AGAddPasswordViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addPasswordViewController:(AGAddPasswordViewController *)controller
                   didAddCredential:(AGCredential *)credential {
    NSError *error;
    
    // convert obj to dictionary as required by the store
    id dict = [credential dictionary];
    // save it
    [self.store save:dict error:&error];

    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Operation Failed!"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // update our local copy
    // set the ID of the object as generated from the store
    credential.recId = dict[@"id"];
    // add it to our local copy
    [_credentials addObject:credential];
    
    // time to add on the table view
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_credentials count] - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths: [NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];

    // dismiss edit modal screen
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIAppplicationBackground notification

-(void)appWillResignActive:(NSNotification*)note {
    [self performSegueWithIdentifier:@"logout" sender:self];
}

@end
