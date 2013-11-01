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
#import "AGInformation.h"

#import "UIActionSheet+Blocks.h"

@implementation AGPasswordManagerViewController {
    NSMutableArray *_entries;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TODO reload from strore
    _entries = [[NSMutableArray alloc] init];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _entries = nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    AGInformation *entry = [_entries objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = entry.name;
    
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
                           [_entries removeObjectAtIndex:[indexPath row]];
                           [tableView deleteRowsAtIndexPaths:@[indexPath]
                                            withRowAnimation:UITableViewRowAnimationFade];

                       } onClickedButton:nil
        ];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // prior to transition, assign delegates to
    // self so we get get notified
	if ([segue.identifier isEqualToString:@"AddPassword"]) {
		UINavigationController *navigationController = segue.destinationViewController;
		AGAddPasswordViewController *addPasswordViewController = [[navigationController viewControllers] objectAtIndex:0];
		addPasswordViewController.delegate = self;
	}
}

# pragma mark - AGAddPasswordViewController Delegate Methods

- (void)addPasswordViewControllerDidCancel:(AGAddPasswordViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addPasswordViewController:(AGAddPasswordViewController *)controller
                   didAddInformation:(AGInformation *)information {
    
    [_entries addObject:information];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_entries count] - 1 inSection:0];
	[self.tableView insertRowsAtIndexPaths: [NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];

	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
