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

#import "AGViewController.h"
#import <AeroGear.h>

@interface AGViewController ()
@end

@implementation AGViewController {
    NSArray *_data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Developers";
    
    NSURL* projectsURL = [NSURL URLWithString:@"http://localhost:8080/aerogear-integration-tests-server/rest"];
    
    // create the server 'Pipeline'
    AGPipeline *server = [AGPipeline pipelineWithBaseURL:projectsURL];
    
    // create the 'Pipe' that will point to the remote '/developer/' endpoint
    id<AGPipe> developerPipe = [server pipe:^(id<AGPipeConfig> config) {
        [config setName:@"/team/developers"];
    }];
    
    [developerPipe read:^(id responseObject) {
        // hold the response
        _data= responseObject;
        
        // refresh table view with the data returned
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"An error has occured during pipe read! \n%@", error);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // extract the developer
    NSDictionary *developer = [_data objectAtIndex:indexPath.row];
    
    // fill cell data
    cell.textLabel.text = [developer objectForKey:@"name"];
    cell.detailTextLabel.text = [developer objectForKey:@"twitter"];
    cell.tag = indexPath.row;
    
    // fetch the twitter image asynchronous
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:
                             [NSURL URLWithString:[developer objectForKey:@"photoURL"]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (cell.tag == indexPath.row) {
                cell.imageView.image = [UIImage imageWithData:imageData];
                [cell setNeedsLayout];
            }
        });
    });
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // extract the developer
    NSDictionary *developer = [_data objectAtIndex:indexPath.row];
    
    // format twitter url
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://twitter.com/%@", [developer objectForKey:@"twitter"]]];
    
    // open twitter page
    [[UIApplication sharedApplication] openURL:url];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
