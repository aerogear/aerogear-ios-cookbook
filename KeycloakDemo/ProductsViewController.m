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

#import "ProductsViewController.h"

#import <AeroGear.h>
#import <SVProgressHUD.h>

@interface ProductsViewController () {
    id<AGPipe> products;

    NSArray *_products;
}
@end

@implementation ProductsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initialize pop-up warning to start OAuth2 authz
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Authorize Keycloak" message:@"You will be redirected to Keycloak to authenticate and grant access." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self authorize:nil];
}

- (IBAction)authorize:(UIButton *)sender {
    AGAuthorizer *authorizer = [AGAuthorizer authorizer];

    id<AGAuthzModule> _restAuthzModule = [authorizer authz:^(id<AGAuthzConfig> config) {
        config.name = @"keycloak";
        config.baseURL = [[NSURL alloc] initWithString:@"http://localhost:8080/auth"];
        config.authzEndpoint = @"/rest/realms/demo/tokens/login";
        config.accessTokenEndpoint = @"/rest/realms/demo/tokens/access/codes";
        config.clientId = @"third-party";
        config.redirectURL = @"org.aerogear.KeycloakDemo://oauth2Callback";
    }];

   [_restAuthzModule requestAccessSuccess:^(id object) {

       AGPipeline *databasePipeline = [AGPipeline pipelineWithBaseURL:[NSURL URLWithString:@"http://localhost:8080/database"]];
        
        products = [databasePipeline pipe:^(id<AGPipeConfig> config) {
            [config setName:@"products"];
            [config setAuthzModule:_restAuthzModule];
        }];
        
        [products read:^(id responseObject) {
            _products = responseObject;

            [self.tableView reloadData];

        } failure:^(NSError *error) {
            NSLog(@"Read: An error occured! \n%@", error);
        }];

    } failure:^(NSError *error) {
        NSLog(@"Read: An error occured! \n%@", error);
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSString *name = _products[indexPath.row];
    cell.textLabel.text = name;
    return cell;
}

@end
