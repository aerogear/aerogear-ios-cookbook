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

#import "AGLocationViewController.h"
#import "AeroDocAPIClient.h"
#import "AGStatus.h"

@implementation AGLocationViewController {
    NSArray *_locations;
    
    NSUInteger _selectedLocation;
}

@synthesize location;
@synthesize delegate;

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locations = @[@"Sao Paulo", @"New York", @"Boston",
                   @"Paris", @"Madrid", @"Munich", @"Rome",
                   @"Athens", @"Lisbon", @"Zurich", @"Amsterdam"];
    
    // select the location passed in initially
    [_locations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([location isEqualToString:obj]) {
            _selectedLocation = idx;
            *stop = YES;
        }
    }];
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                   target:self
                                                                                   action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    location =  [AeroDocAPIClient sharedInstance].location;
    int i = 0;
    for (NSString *loc in _locations) {
        if ([loc isEqualToString:location]) {
            _selectedLocation = i;
        }
        i++;
    }
}

#pragma mark - Table View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (_selectedLocation == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = _locations[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != _selectedLocation) {
        if (_selectedLocation != NSNotFound) {
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:_selectedLocation
                                                           inSection:0];
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedLocation = indexPath.row;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (void)done {
    [self.delegate didChangeLocation:self location:_locations[_selectedLocation]];
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
