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
#import "AeroGear.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SVProgressHUD.h"

@interface AGViewController ()
@end

@implementation AGViewController {
    id<AGAuthzModule> _restAuthzModule;
    NSMutableArray* _documents;
    NSString* _userName;
    NSIndexPath* _indexPathToActOn;
    
    UISegmentedControl *_segmentedControl;
    
    id<AGPipe> _gdAboutPipe;
    id<AGPipe> _gdFilesPipe;
}

@synthesize documents = _documents;
@synthesize tableView;
@synthesize revokeButton;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_documents count];
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"DocumentCell";
    
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [[_documents objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    NSArray* owners = [[_documents objectAtIndex:indexPath.row] objectForKey:@"ownerNames"];
    NSString* ownerNames = [owners componentsJoinedByString:@","];
    ownerNames = [ownerNames stringByReplacingOccurrencesOfString:_userName withString:@"You"];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Owner%@: %@", owners.count>1?@"(s)":@"", ownerNames];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray* ownerNames = [[_documents objectAtIndex:indexPath.row] objectForKey:@"ownerNames"];
    //We shall make those documents editable that belongs only to current user.
    if (ownerNames.count == 1 && [ownerNames[0] isEqualToString:_userName]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Update title?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 3;
        [[alert textFieldAtIndex:0] setText:[[_documents objectAtIndex:indexPath.row] objectForKey:@"title"]];
        _indexPathToActOn = indexPath;
        [alert show];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray* ownerNames = [[_documents objectAtIndex:indexPath.row] objectForKey:@"ownerNames"];
    //We shall make those documents editable that belongs only to current user.
    if (ownerNames.count == 1 && [ownerNames[0] isEqualToString:_userName]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Delete document?" message:@"Proceeding with delete will permanently delete the document from Google Drive. Are you sure you want to continue?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    
    alert.alertViewStyle = UIAlertViewStyleDefault;
    alert.tag = 2;  //Not nice to use magic numbers but just for the sake of this example
    _indexPathToActOn = indexPath;
    [alert show];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [revokeButton setEnabled:NO];
    
    //Set up segmenteed control
    NSArray *segItemsArray = [NSArray arrayWithObjects: @"Simple", @"Multipart", nil];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:segItemsArray];
    _segmentedControl.frame = CGRectMake(0, 0, 150, 30);
    _segmentedControl.selectedSegmentIndex = 1;
    [self.barButtonChoice setCustomView:_segmentedControl];
    
    // Initialize pop-up warning to start OAuth2 authz
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Authorize GoogleDrive" message:@"Do you want to authorize GoogleDrive to access your Google Drive data? You will be redirected to Google login to authenticate and grant access." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    alert.tag = 1;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1:
            [self authorize:nil];
            break;
            
        case 2:
            if (buttonIndex == 1) {
                [self deleteDocumentAtIndexPath:_indexPathToActOn];
                _indexPathToActOn = nil;
            }
            break;
        
        case 3:
            if (buttonIndex == 1) {
                NSString* newTitle = [alertView textFieldAtIndex:0].text;
                [self updateDocumentAtIndexPath:_indexPathToActOn withTitle:newTitle];
                _indexPathToActOn = nil;
            }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)authorize:(UIButton *)sender {
    AGAuthorizer* authorizer = [AGAuthorizer authorizer];
    
    _restAuthzModule = [authorizer authz:^(id<AGAuthzConfig> config) {
        config.name = @"restAuthMod";
        config.baseURL = [[NSURL alloc] initWithString:@"https://accounts.google.com"];
        config.authzEndpoint = @"/o/oauth2/auth";
        config.accessTokenEndpoint = @"/o/oauth2/token";
        config.revokeTokenEndpoint = @"/o/oauth2/revoke";
        config.clientId = @"<your client secret goes here.apps.googleusercontent.com>";
        config.redirectURL = @"org.aerogear.GoogleDrive:/oauth2Callback";
        config.scopes = @[@"https://www.googleapis.com/auth/drive"];
    }];
    
    NSURL* googleDriveURL = [NSURL URLWithString:@"https://www.googleapis.com/drive/v2"];
    AGPipeline* gdPipeline = [AGPipeline pipelineWithBaseURL:googleDriveURL];
    
    _gdAboutPipe = [gdPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"about"];
        [config setAuthzModule:_restAuthzModule];
    }];
    
    _gdFilesPipe = [gdPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"files"];
        [config setAuthzModule:_restAuthzModule];
    }];
    
    [self loadAll];
}

#pragma mark - Button Actions
- (IBAction)revoke:(id)sender {
    [_restAuthzModule revokeAccessSuccess:^(id object) {
        [revokeButton setEnabled:NO];
        _userName = nil;
        [self clearDocuments];
    } failure:^(NSError *error) {
        NSLog(@"%s: Revoke failed with error: \n%@",__PRETTY_FUNCTION__, error.description);
    }];
}

-(void)clearDocuments {
    _documents = nil;
    [self.tableView reloadData];
}

- (IBAction)refreshDocument:(id)sender {
    if (!_userName) {
        [self loadAll];
    }else {
        [self loadDocuments];
    }
}

- (IBAction)useCamera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (IBAction)useCameraRoll:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - Utility methods for core calls
- (void)loadAll {
    [SVProgressHUD showWithStatus:@"Fetching user info..." maskType:SVProgressHUDMaskTypeBlack];
    
    [self getUserInfo:^(id responseObj) {
        [revokeButton setEnabled:YES];
        _userName = responseObj[@"name"];
        [SVProgressHUD showWithStatus:@"Fetching documents..." maskType:SVProgressHUDMaskTypeBlack];
        [self fetchGoogleDriveDocuments:^(id responseObj) {
            _documents = [responseObj[@"items"] copy];
            [SVProgressHUD showSuccessWithStatus:@"Successfully fetched!"];
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Failed to fetch documents!"];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to get user info!"];
    }];
}

- (void)loadDocuments {
    [SVProgressHUD showWithStatus:@"Fetching documents..." maskType:SVProgressHUDMaskTypeBlack];
    [self fetchGoogleDriveDocuments:^(id responseObj) {
        [revokeButton setEnabled:YES];
        _documents = [responseObj[@"items"] copy];
        [SVProgressHUD showSuccessWithStatus:@"Successfully fetched!"];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to fetch documents!"];
    }];
}

- (void)deleteDocumentAtIndexPath:(NSIndexPath*)indexPath {
    [SVProgressHUD showWithStatus:@"Deleting document..." maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* docId = [[_documents objectAtIndex:indexPath.row] objectForKey:@"id"];
    [self deleteGoogleDriveDocumentOfId:docId success:^{
        [SVProgressHUD showWithStatus:@"Deleted successfully! Reloading documents now..." maskType:SVProgressHUDMaskTypeBlack];
        [self fetchGoogleDriveDocuments:^(id responseObj) {
            _documents = [responseObj[@"items"] copy];
            [SVProgressHUD showSuccessWithStatus:@"Successfully loaded!"];
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Failed to fetch documents!"];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to delete!"];
    }];
}

- (void)updateDocumentAtIndexPath:(NSIndexPath*)indexPath withTitle:(NSString*)title {
    [SVProgressHUD showWithStatus:@"Updating document title..." maskType:SVProgressHUDMaskTypeBlack];
    
    NSString* docId = [[_documents objectAtIndex:indexPath.row] objectForKey:@"id"];
    [self updateGoogleDriveDocumentOfId:docId withTitle:title success:^{
        [SVProgressHUD showWithStatus:@"Updated successfully! Reloading documents now..." maskType:SVProgressHUDMaskTypeBlack];
        [self fetchGoogleDriveDocuments:^(id responseObj) {
            _documents = [responseObj[@"items"] copy];
            [SVProgressHUD showSuccessWithStatus:@"Successfully loaded!"];
            [self.tableView reloadData];
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Failed to fetch documents!"];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to update!"];
    }];
}

- (void)uploadImage:(UIImage*)image {
    if (_segmentedControl.selectedSegmentIndex == 0) {
        [self simpleUploadImage:image];
    }else {
        [self multiPartUploadImage:image];
    }
}

#pragma mark - Core Google Drive Pipe methods
- (void)getUserInfo:(void (^)(id responseObj))success
                       failure:(void (^)(NSError *error))failure {
    
    [_gdAboutPipe read:^(id responseObject) {
        success(responseObject[0]);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

-(void)fetchGoogleDriveDocuments:(void (^)(id responseObj))success
                         failure:(void (^)(NSError *error))failure {
    [_gdFilesPipe read:^(id responseObject) {
        success(responseObject[0]);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)deleteGoogleDriveDocumentOfId:(NSString*)docId success:(void (^)())success
                                     failure:(void (^)(NSError *error))failure {
    [_gdFilesPipe remove:@{@"id": docId} success:^(id responseObject) {
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)updateGoogleDriveDocumentOfId:(NSString*)docId withTitle:(NSString*)title success:(void (^)())success
                                     failure:(void (^)(NSError *error))failure {
    [_gdFilesPipe save:@{@"id": docId, @"title": title} success:^(id responseObject) {
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)simpleUploadImage:(UIImage*)image {
    
    NSData *imgData = UIImageJPEGRepresentation(image, 0.2);
    // set up payload with the image
    AGFileDataPart *imageDataPart = [[AGFileDataPart alloc] initWithFileData:imgData
                                                                   name:@"image"
                                                               fileName:@"image.jpg"
                                                               mimeType:@"image/jpeg"];
    
    NSURL *gUrl = [NSURL URLWithString:@"https://www.googleapis.com"];
    AGPipeline* gPipeline = [AGPipeline pipelineWithBaseURL:gUrl];
    
    // set up upload pipe
    id<AGPipe> uploadPipe = [gPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"upload/drive/v2/files"];
        [config setAuthzModule:_restAuthzModule];
    }];
    
    // set up metadata pipe
    id<AGPipe> metaPipe = [gPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"drive/v2/files"];
        [config setAuthzModule:_restAuthzModule];
    }];
    
    NSDictionary *dict = @{@"data:": imageDataPart};
    
    // show a progress indicator
    [uploadPipe setUploadProgressBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:(totalBytesSent/(float)totalBytesExpectedToSend) status:@"Simple uploading, please wait..." maskType:SVProgressHUDMaskTypeBlack];
        });
    }];
    
    // upload file
    [uploadPipe save:dict success:^(id responseObject) {
        // time to set metadata
        
        // extract the "id" assigned from the response
        NSString *fileId = [responseObject objectForKey:@"id"];
        // set the filename
        NSDictionary *params = @{ @"id":fileId, @"title": image.accessibilityIdentifier};
        
        // set metadata
        [metaPipe save:params success:^(id responseObject) {
            [SVProgressHUD showWithStatus:@"Uploaded Successfully! Reloading documents now..." maskType:SVProgressHUDMaskTypeBlack];
            [self fetchGoogleDriveDocuments:^(id responseObj){
                [SVProgressHUD showSuccessWithStatus:@"Successfully loaded!"];
                _documents = [responseObj[@"items"] copy];
                [self.tableView reloadData];
                [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
            } failure:^(NSError *error) {
                [SVProgressHUD showErrorWithStatus:@"Failed to fetch documents!"];
            }];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Failed to set metadata!"];
        }];
        
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to upload!"];
    }];
}

- (void)multiPartUploadImage:(UIImage*)image {
    
    NSData *imgData = UIImageJPEGRepresentation(image, 0.2);
    AGFileDataPart *imageDataPart = [[AGFileDataPart alloc] initWithFileData:imgData
                                                                        name:@"image"
                                                                    fileName:@"image.jpg"
                                                                    mimeType:@"image/jpeg"];
    
    
    NSDictionary* metaDataDict = @{@"title": image.accessibilityIdentifier,
                                   @"mimeType" : @"image/jpeg"};
    
    NSData* metaDataData = [NSJSONSerialization dataWithJSONObject:metaDataDict options:0 error:nil];
    AGFileDataPart *metaDataPart = [[AGFileDataPart alloc] initWithFileData:metaDataData name:@"image" fileName:@"image.jpg" mimeType:@"application/json"];
    
    //Now let's try to upload this file
    NSURL* serverURL = [NSURL URLWithString:@"https://www.googleapis.com/upload/drive/v2"];
    AGPipeline* googleDocuments = [AGPipeline pipelineWithBaseURL:serverURL];
    
    id<AGPipe> uploadPipe = [googleDocuments pipe:^(id<AGPipeConfig> config) {
        [config setName:@"files?uploadType=multipart"];
        [config setAuthzModule:_restAuthzModule];
    }];
    
    
    // show a progress indicator
    [uploadPipe setUploadProgressBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:(totalBytesSent/(float)totalBytesExpectedToSend) status:@"Multipart uploading, please wait" maskType:SVProgressHUDMaskTypeBlack];
        });
    }];
    
    // set up payload
    NSDictionary *dict = @{@"data1":metaDataPart,
                           @"data2":imageDataPart
                           };
    
    [uploadPipe save:dict  success:^(id responseObject) {
        [SVProgressHUD showWithStatus:@"Uploaded Successfully! Reloading documents now..." maskType:SVProgressHUDMaskTypeBlack];
        [self fetchGoogleDriveDocuments:^(id responseObj){
            [SVProgressHUD showSuccessWithStatus:@"Successfully loaded!"];
            
            _documents = [responseObj[@"items"] copy];
            [self.tableView reloadData];
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Failed to fetch documents!"];
        }];
    } failure:^(NSError *error) {
        NSLog(@"%s: Uploading document failed with error: \n%@", __PRETTY_FUNCTION__, error.description);
        [SVProgressHUD showErrorWithStatus:@"Failed to upload!"];
    }];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
            ALAssetRepresentation *representation = [myasset defaultRepresentation];
            image.accessibilityIdentifier = [representation filename];
            if (!image.accessibilityIdentifier) {
                // This is camera image
                image.accessibilityIdentifier = @"Untitled.jpg";
            }
            
            // Let's upload now
            if (!_userName) {
                [self getUserInfo:^(id responseObj) {
                    [revokeButton setEnabled:YES];
                    _userName = responseObj[@"name"];
                    [self uploadImage:image];
                } failure:^(NSError *error) {
                    NSLog(@"%s: Failed to load user info with: \n%@", __PRETTY_FUNCTION__, error.description);
                }];
            }else {
                [self uploadImage:image];
            }
            
        };
        
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:imageURL
                       resultBlock:resultblock
                      failureBlock:nil];

    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        // Code here to support video if enabled
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
