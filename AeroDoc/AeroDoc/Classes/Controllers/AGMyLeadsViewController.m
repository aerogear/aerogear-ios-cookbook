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

#import "AGMyLeadsViewController.h"
#import "AGLeadViewController.h"
#import "AeroDocAPIClient.h"
#import "AGLead.h"
#import "LeadCell.h"
#import "AGStatus.h"

@implementation AGMyLeadsViewController {
    NSMutableArray *_leads;
    id<AGStore> _localStore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    _localStore = [[AeroDocAPIClient sharedInstance] localStore];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(myLeadRefresh) name:@"NewMyLeadNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(statusButtonItem) name:@"SatusChanged" object:nil];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(myLeadRefresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    [self displayLeads];
}

- (void) displayLeads {
    _leads = [[_localStore readAll] mutableCopy];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // unregister our notification listener
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:@"NewMyLeadNotification" object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:@"SatusChanged" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_leads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    LeadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSInteger row = [indexPath row];
    AGLead *lead = [[AGLead alloc] initWithDictionary: [_leads objectAtIndex:row]];
    if (cell == nil) {
        cell = [[LeadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTableView:tableView andIndexPath:indexPath withImageDisplay:NO];
    }

    [cell decorateCell:row inListCount:[_leads count] with:NO];
    
    cell.topLabel.text = [NSString stringWithFormat:@"%@.", lead.name];
    cell.bottomLabel.text = [NSString stringWithFormat:@"at: %@", lead.location];
    
    return cell;
}


- (void) myLeadRefresh {
    [self displayLeads];
    [self.tableView reloadData];
}

- (void)changeStatus {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Change your Status:"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"PTO"
                                  otherButtonTitles:@"StandBy", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // no need to do anything if user clicks cancel
    if (buttonIndex == 2)
        return;
    
    NSString *status = (buttonIndex == 0? @"PTO": @"STANDBY");
    
    [[AeroDocAPIClient sharedInstance] changeStatus:status success:^{
        // if succeeded, update the status bar
        for (UIViewController *controller in [AGStatus targetsList]) {
            controller.navigationItem.leftBarButtonItem = [[AGStatus sharedInstance] changeStatusOnTarget:controller];
        }
        
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"An error has occured changing status!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];
    }];    
}


@end