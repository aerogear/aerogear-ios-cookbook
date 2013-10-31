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

#import "AGPasswordListViewController.h"

@implementation AGPasswordListViewController

@synthesize passwords = _passwords;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
//    // set up navigation button items
//    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
//                                                                                   target:self
//                                                                                   action:@selector(displayLeads)];
//    self.navigationItem.rightBarButtonItem = refreshButton;
//    
//    // register to receive the notification
//    // when a new lead is pushed
//    [[NSNotificationCenter defaultCenter]
//        addObserver:self selector:@selector(leadPushed:) name:@"LeadAddedNotification" object:nil];
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self selector:@selector(leadAccepted:) name:@"LeadAcceptedNotification" object:nil];
//    
    [self displayProjects];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // unregister our notification listener
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:@"LeadAddedNotification" object:nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:@"LeadAcceptedNotification" object:nil];
}

- (void) displayProjects {
//    [[AeroDocAPIClient sharedInstance] fetchLeads:^(NSMutableArray *leads) {
//        _leads = leads;
//              
//        [self.tableView reloadData];
//    
//    } failure:^(NSError *error) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
//                                                        message:[error localizedDescription]
//                                                       delegate:nil
//                                              cancelButtonTitle:@"Bummer"
//                                              otherButtonTitles:nil];
//        [alert show];
//    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_passwords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
//    LeadCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    NSInteger row = [indexPath row];
//    AGLead *lead = [_leads objectAtIndex:row];
//    
//    if (cell == nil) {
//        cell = [[LeadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withTableView:tableView andIndexPath:indexPath withImageDisplay:NO];
//    }
//    // check if list belong to list of pushed leads to display it with star icon
//    NSArray *_pushedLeads = [[AeroDocAPIClient sharedInstance].pushedLocalStore readAll];
//    BOOL isPushed = [self isLead:lead in:_pushedLeads];
//    [cell decorateCell:row inListCount:[self.leads count] with:isPushed];
//    
//    cell.topLabel.text = [NSString stringWithFormat:@"%@.", lead.name];
//    cell.bottomLabel.text = [NSString stringWithFormat:@"at: %@", lead.location];
	   
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
//    AGLead *lead = [_leads objectAtIndex:row];
//    
//    AGLeadViewController *leadController = [[AGLeadViewController alloc] init];
//    leadController.delegate = self;
//    leadController.lead = lead;
//    leadController.hidesBottomBarWhenPushed = YES;
//    
//	[self.navigationController pushViewController:leadController animated:YES];
}


//- (void) remove:(AGLead*)lead from:(NSMutableArray*)list {
//    int i;
//    for(i=0; i<[list count]; i++) {
//        AGLead *currentLead = [list objectAtIndex:i];
//        if([currentLead.recId isEqual:lead.recId]) {
//            [list removeObjectAtIndex:i];
//            i--;
//        }
//    }
//}


@end