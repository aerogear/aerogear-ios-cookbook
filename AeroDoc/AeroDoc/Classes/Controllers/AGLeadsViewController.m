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
#import "AGLeadsViewController.h"
#import "AGLeadViewController.h"
#import "AeroDocAPIClient.h"
#import "AGLead.h"
#import "LeadCell.h"
#import "AGStatus.h"

@implementation AGLeadsViewController

@synthesize leads = _leads;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    // set up navigation button items
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                   target:self
                                                                                   action:@selector(displayLeads)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    // register to receive the notification
    // when a new lead is pushed
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(leadPushed:) name:@"LeadAddedNotification" object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(leadAccepted:) name:@"LeadAcceptedNotification" object:nil];
    
    [self displayLeads];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // unregister our notification listener
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:@"LeadAddedNotification" object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:@"LeadAcceptedNotification" object:nil];
}

- (void) displayLeads {
    [[AeroDocAPIClient sharedInstance] fetchLeads:^(NSMutableArray *leads) {
        _leads = leads;
              
        [self.tableView reloadData];
    
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];
    }];
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
    AGLead *lead = [_leads objectAtIndex:row];
    
    if (cell == nil) {
        cell = [[LeadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTableView:tableView andIndexPath:indexPath withImageDisplay:NO];
    }
    // check if list belong to list of pushed leads to display it with star icon
    NSArray *_pushedLeads = [[AeroDocAPIClient sharedInstance].pushedLocalStore readAll];
    BOOL isPushed = [self isLead:lead in:_pushedLeads];
    [cell decorateCell:row inListCount:[self.leads count] with:isPushed];
    
    cell.topLabel.text = [NSString stringWithFormat:@"%@.", lead.name];
    cell.bottomLabel.text = [NSString stringWithFormat:@"at: %@", lead.location];
	   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    AGLead *lead = [_leads objectAtIndex:row];
    
    AGLeadViewController *leadController = [[AGLeadViewController alloc] init];
    leadController.delegate = self;
    leadController.lead = lead;
    leadController.hidesBottomBarWhenPushed = YES;
    
	[self.navigationController pushViewController:leadController animated:YES];
}

//------------------------------------------------------
// Once the lead is accepted by user logged. Send update
// and store my leads locally
//------------------------------------------------------
- (void)didAccept:(AGLeadViewController *)controller lead:(AGLead *)lead {
    [[AeroDocAPIClient sharedInstance] postLead:lead success:^{
        // add it to the local store
        NSError *error = nil;
        if (![[AeroDocAPIClient sharedInstance].localStore save:[lead dictionary] error:&error]) {
            DLog(@"Save: An error occured during save! \n");
        }
    
        } failure:^(NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"An error has occured during save!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Bummer"
                                                  otherButtonTitles:nil];
            [alert show];
        }];

}

- (void)didDismiss:(AGLeadViewController *)controller lead:(AGLead *)lead {

}

- (void)didChangeLocation:(AGLocationViewController *)controller location:(NSString*)location {
    [[AeroDocAPIClient sharedInstance] changeLocation:location success:^{
        
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"An error has occured changing status!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Bummer"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (BOOL) isLead:(AGLead*)lead in:(NSArray*)list {
    int i;
    for(i=0; i<[list count]; i++) {
        //AGLead *currentLead = [list objectAtIndex:i];
        AGLead *currentLead = [[AGLead alloc] initWithDictionary: [list objectAtIndex:i]];
        NSNumber* currentId = (NSNumber*)currentLead.recId;
        NSNumber* recId = (NSNumber*)lead.recId;
        NSString* strCurrentId = [NSString stringWithFormat:@"%@", currentId];
        NSString* strId = [NSString stringWithFormat:@"%@", recId];
        
        if([strCurrentId isEqual:strId]) {
            return YES;
            i--;
        }
    }
    return NO;
}

- (void) remove:(AGLead*)lead from:(NSMutableArray*)list {
    int i;
    for(i=0; i<[list count]; i++) {
        AGLead *currentLead = [list objectAtIndex:i];
        if([currentLead.recId isEqual:lead.recId]) {
            [list removeObjectAtIndex:i];
            i--;
        }
    }
}

#pragma mark - Notification
//------------------------------------------------------
// Callback method for NSNotification for
// LeadAcceptedNotification, thrown in AGAppDelegate
// application:didReceiveRemoteNotification: on receipt of
// push notification. Actions is:
// - Save loccally all pushed leads.
// - Retrieve all open leads from server.
// - Redisplay table with star icon for pushed leads.
//------------------------------------------------------
- (void)leadPushed:(NSNotification *)notification {
    NSString *leadName= [notification.object objectForKey:@"name"];
    AGLead *lead = [[AGLead alloc] initWithDictionary:notification.object];
    NSError *error = nil;
    
    if (![[AeroDocAPIClient sharedInstance].pushedLocalStore save:[lead dictionary] error:&error]) {
        DLog(@"Save: An error occured during save to pushedLocalStorage!\n");
    }
    
    [self displayLeads];
    [self.tableView reloadData];
    
    DLog(@"leadPushed on notification called for lead %@", leadName);
}

//------------------------------------------------------
// Callback method for NSNotification for
// LeadAddedNotification, thrown in AGAppDelegate
// application:didReceiveRemoteNotification: on receipt of
// push notification. Actions is:
// - Save loccally all pushed leads.
// - Retrieve all open leads from server.
// - Redisplay table with star icon for pushed leads.
//------------------------------------------------------
- (void)leadAccepted:(NSNotification *)notification {
    NSString *temp= [notification.object objectForKey:@"name"];
    DLog(@"Start of leadAccepted on notification called %@", temp);

    AGLead *lead = [[AGLead alloc] initWithDictionary:notification.object];
    DLog(@"%@ %@", lead.recId, lead.name);
    [self remove:lead from:_leads];
    [self.tableView reloadData];
    
    // Refresh MyLeads table
    NSNotification *myNotification = [NSNotification notificationWithName:@"NewMyLeadNotification"
                                                                   object:lead];
    [[NSNotificationCenter defaultCenter] postNotification:myNotification];
    DLog(@"End of leadAccepted on notification called");
}

#pragma mark - Navigation Button

- (void)showLocationChooser {
    AGLocationViewController *locController = [[AGLocationViewController alloc] initWithStyle:UITableViewStylePlain];
    
    locController.location = [AeroDocAPIClient sharedInstance].location;
    locController.delegate = self;
    
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:locController];
    [self.navigationController presentModalViewController:controller animated:YES];
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