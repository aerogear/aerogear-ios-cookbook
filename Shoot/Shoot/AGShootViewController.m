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
    id<AGAuthzModule> _googleAuthzModule;
    id<AGAuthzModule> _facebookAuthzModule;
    NSMutableDictionary *_tokens;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tokens = [NSMutableDictionary dictionary];
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
    NSString *filename = self.imageView.accessibilityIdentifier;
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Google", nil];
    
    [actionSheet showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Facebook"]) {
        [self shareWithFacebook];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Google"]) {
        [self shareWithGoogleDrive];
    }
}

-(void)oauthFacebook {
    // start up the authorization process
    AGAuthorizer* authorizer = [AGAuthorizer authorizer];
    
    // TODO replace XXX -> secret and 765891443445434 -> your app id in this file + plist file
    _facebookAuthzModule = [authorizer authz:^(id<AGAuthzConfig> config) {
        config.name = @"restAuthMod";
        config.baseURL = [[NSURL alloc] init];
        config.authzEndpoint = @"https://www.facebook.com/dialog/oauth";
        config.accessTokenEndpoint = @"https://graph.facebook.com/oauth/access_token";
        config.clientId = @"765891443445434";
        config.clientSecret = @"XXX";
        config.redirectURL = @"fb765891443445434://authorize/";
        config.scopes = @[@"user_friends, public_profile, publish_stream,user_photos,user_photo_video_tags, photo_upload, publish_actions"];
        config.type = @"AG_OAUTH2_FACEBOOK";
    }];
    [_facebookAuthzModule requestAccessSuccess:^(id response) {
        _tokens[@"Facebook"] = response;
        [self shareWithFacebook];
        NSLog(@"Success to authorize %@", response);
        
    } failure:^(NSError *error) {
        NSLog(@"Failure to authorize");
    }];
}

-(void)oauthGoogle {
    // start up the authorization process
    AGAuthorizer* authorizer = [AGAuthorizer authorizer];
    
    _googleAuthzModule = [authorizer authz:^(id<AGAuthzConfig> config) {
        config.name = @"restAuthMod";
        config.baseURL = [[NSURL alloc] initWithString:@"https://accounts.google.com"];
        config.authzEndpoint = @"/o/oauth2/auth";
        config.accessTokenEndpoint = @"/o/oauth2/token";
        config.clientId = @"873670803862-g6pjsgt64gvp7r25edgf4154e8sld5nq.apps.googleusercontent.com";
        config.redirectURL = @"org.aerogear.Shoot:/oauth2Callback";
        config.scopes = @[@"https://www.googleapis.com/auth/drive"];
        config.type = @"AG_OAUTH2";
    }];
    [_googleAuthzModule requestAccessSuccess:^(id response) {
        _tokens[@"Google"] = response;
        [self shareWithGoogleDrive];
        NSLog(@"Success to authorize %@", response);
        
    } failure:^(NSError *error) {
        NSLog(@"Failure to authorize");
    }];
}

- (void)shareWithGoogleDrive {
    if (!_tokens[@"Google"]) {
        [self oauthGoogle];
    } else {
        // extract the image filename
        NSString *filename = self.imageView.accessibilityIdentifier;
        
        
        // the Google API base URL
        NSURL *gUrl = [NSURL URLWithString:@"https://www.googleapis.com"];
        
        AGPipeline* gPipeline = [AGPipeline pipelineWithBaseURL:gUrl];
        
        // set up upload pipe
        id<AGPipe> uploadPipe = [gPipeline pipe:^(id<AGPipeConfig> config) {
            [config setName:@"upload/drive/v2/files"];
            [config setAuthzModule:_googleAuthzModule];
        }];
        
        // set up metadata pipe
        id<AGPipe> metaPipe = [gPipeline pipe:^(id<AGPipeConfig> config) {
            [config setName:@"drive/v2/files"];
            [config setAuthzModule:_googleAuthzModule];
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
        [uploadPipe setUploadProgressBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showProgress:(totalBytesSent/(float)totalBytesExpectedToSend) status:@"uploading, please wait"];
            });
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
}

-(void)shareWithFacebook {
    if (!_tokens[@"Facebook"]) {
        [self oauthFacebook];
    } else {
        
        // extract the image filename
        NSString *filename = self.imageView.accessibilityIdentifier;;
        
        // the Facebook API base URL, you need to
        NSURL *gUrl = [NSURL URLWithString:@"https://graph.facebook.com/me/"];
        
        AGPipeline* gPipeline = [AGPipeline pipelineWithBaseURL:gUrl];
        
        // set up upload pipe
        id<AGPipe> uploadPipe = [gPipeline pipe:^(id<AGPipeConfig> config) {
            [config setName:@"photos"];
            [config setAuthzModule:_facebookAuthzModule];
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
        [uploadPipe setUploadProgressBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showProgress:(totalBytesSent/(float)totalBytesExpectedToSend) status:@"uploading, please wait"];
            });
        }];
        
        // upload file
        [uploadPipe save:dict success:^(id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"Successfully uploaded!"];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Failed to upload!"];
        }];
    }
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


@end
