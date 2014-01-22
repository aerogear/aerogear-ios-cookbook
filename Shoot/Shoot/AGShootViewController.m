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

#import "AGShootViewController.h"
#import "AeroGear.h"

#import "SVProgressHUD.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AGAppDelegate.h"

@interface AGShootViewController ()
    @property BOOL newMedia;
    @property (strong, nonatomic) IBOutlet UIImageView *imageView;

    - (IBAction)useCamera:(id)sender;
    - (IBAction)useCameraRoll:(id)sender;
    - (IBAction)share:(id)sender;
@end

@implementation AGShootViewController {
    id<AGAuthzModule> _restAuthzModule;
    
    NSString *_token;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // initially, ask the user to authorize app on Google
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Google Authorization"
                          message: @"Before you can upload media, you must authorize this app to access your Google Drive. When you click OK you will be redirected to Google for authorization."
                          delegate: self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    [alert show];
}

#pragma mark - Toolbar Actions

- (void) useCamera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        _newMedia = YES;
    }
}

- (void) useCameraRoll:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        _newMedia = NO;
    }
}

- (IBAction)share:(id)sender {
    // extract the image filename
    NSString *filename = self.imageView.accessibilityIdentifier;;
    
    if (filename == nil) { // nothing was selected
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Error"
                              message: @"Please select an image first!"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    // the Google API base URL
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
    
    // Get currently displayed image
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
    
    // set up payload with the image
    AGFileDataPart *dataPart = [[AGFileDataPart alloc] initWithFileData:imageData
                                                                   name:@"image"
                                                               fileName:filename
                                                               mimeType:@"image/jpeg"];
    NSDictionary *dict = @{@"data:": dataPart};
    
    // show a progress indicator
    [uploadPipe setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        [SVProgressHUD showProgress:(totalBytesWritten/(float)totalBytesExpectedToWrite)
                             status:@"uploading, please wait"];
    }];
    
    // upload file
    [uploadPipe save:dict success:^(id responseObject) {
        // time to set metadata
        
        // extract the "id" assigned from the response
        NSString *fileId = [responseObject objectForKey:@"id"];
        // set the filename
        NSDictionary *params = @{ @"id":fileId, @"title": filename};
        
        // set metadata
        [metaPipe save:params success:^(id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"Successfully uploaded!"];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Failed to set metadata!"];
        }];
        
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Failed to upload!"];
    }];
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        if (_newMedia) {
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
            self.imageView.accessibilityIdentifier = @"Untitled.jpg";
                
        } else {
            NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
            ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
                ALAssetRepresentation *representation = [myasset defaultRepresentation];
                self.imageView.accessibilityIdentifier = [representation filename];
            };
            
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
            [assetslibrary assetForURL:imageURL
                           resultBlock:resultblock
                          failureBlock:nil];
        }
        
        self.imageView.image = image;

        [SVProgressHUD showSuccessWithStatus:@"image added!"];
        
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        // Code here to support video if enabled
    }
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonInden {
    // start up the authorization process
    AGAuthorizer* authorizer = [AGAuthorizer authorizer];
    
    _restAuthzModule = [authorizer authz:^(id<AGAuthzConfig> config) {
        config.name = @"restAuthMod";
        config.baseURL = [[NSURL alloc] initWithString:@"https://accounts.google.com"];
        config.authzEndpoint = @"/o/oauth2/auth";
        config.accessTokenEndpoint = @"/o/oauth2/token";
        config.clientId = @"873670803862-g6pjsgt64gvp7r25edgf4154e8sld5nq.apps.googleusercontent.com";
        config.redirectURL = @"org.aerogear.Shoot:/oauth2Callback";
        config.scopes = @[@"https://www.googleapis.com/auth/drive"];
    }];
    
    [_restAuthzModule requestAccessSuccess:^(id response) {
        _token = response;
        
    } failure:^(NSError *error) {
    }];
}

@end
