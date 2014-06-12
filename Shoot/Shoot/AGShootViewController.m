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
#import "SVProgressHUD.h"

#import <AeroGear/AeroGear.h>
#import <AeroGear-Crypto/AeroGearCrypto.h>

#import <AssetsLibrary/AssetsLibrary.h>

// the salt
static NSString *const kSalt = @"nsalt";

@interface AGShootViewController ()
    @property BOOL newMedia;
    @property (strong, nonatomic) IBOutlet UIImageView *imageView;

    - (IBAction)useCamera:(id)sender;
    - (IBAction)useCameraRoll:(id)sender;
    - (IBAction)share:(id)sender;
@end

@implementation AGShootViewController {
    AGAccountManager *_acctManager;
    
    AGPipeline *_fbPipeline;
    AGPipeline *_gPipeline;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // show the password screen for user to enter his password
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Enter passphrase"
                                                     message:@"Enter your passphrase:" delegate:self
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];    
}

- (void)setup:(NSString *)passphrase {
    // set up crypto params configuration object
    AGPassphraseCryptoConfig *config = [[AGPassphraseCryptoConfig alloc] init];
    [config setSalt:[self salt]];
    [config setPassphrase:passphrase];
    
    // initialize the encryption service passing the config
    id<AGEncryptionService> encService = [[AGKeyManager manager] keyService:config];
    
    // access Store Manager
    AGDataManager *manager = [AGDataManager manager];
    
    // create store
    id<AGStore> store = [manager store:^(id<AGStoreConfig> config) {
        [config setName:@"OAuthStorage"];
        // can also be set to "ENCRYPTED_SQLITE" for the encrypted sqlite variant
        [config setType:@"ENCRYPTED_PLIST"];
        [config setEncryptionService:encService];
    }];
    
    // initialize account manager with encrypted store backend
    _acctManager = [AGAccountManager manager:store];

    // set up facebook and google authz modules

    // TODO replace XXX -> client_id, YYY -> client_secret,  ZZZ -> your app id in this file + plist file
    id<AGAuthzModule> facebookAuthzModule = [_acctManager authz:^(id<AGAuthzConfig> config) {
        config.accountId = @"my_facebook_account";
        config.name = @"facebook";
        config.baseURL = [NSURL URLWithString:@"https://www.facebook.com"];
        config.authzEndpoint = @"/dialog/oauth";
        config.accessTokenEndpoint = @"https://graph.facebook.com/oauth/access_token";
        config.clientId = @"XXX";
        config.clientSecret = @"YYY";
        config.redirectURL = @"fbZZZ://authorize/";
        config.scopes = @[@"user_friends, public_profile, publish_stream,user_photos,user_photo_video_tags, photo_upload, publish_actions"];
        config.type = @"AG_OAUTH2_FACEBOOK";
    }];
    
    id<AGAuthzModule> googleAuthzModule = [_acctManager authz:^(id<AGAuthzConfig> config) {
        config.accountId = @"my_google_account";
        config.name = @"google";
        config.baseURL = [NSURL URLWithString:@"https://accounts.google.com"];
        config.authzEndpoint = @"/o/oauth2/auth";
        config.accessTokenEndpoint = @"/o/oauth2/token";
        config.clientId = @"873670803862-g6pjsgt64gvp7r25edgf4154e8sld5nq.apps.googleusercontent.com";
        config.redirectURL = @"org.aerogear.Shoot:/oauth2Callback";
        config.scopes = @[@"https://www.googleapis.com/auth/drive"];
        config.type = @"AG_OAUTH2";
    }];
    
    // set up our facebook pipeline and pipes
    _fbPipeline = [AGPipeline pipelineWithBaseURL:[NSURL URLWithString:@"https://graph.facebook.com/me/"]];

    [_fbPipeline pipe:^(id<AGPipeConfig> config) {
            [config setName:@"facebookUploadPipe"];
            // the Facebook API base URL, you need to
            [config setEndpoint:@"photos"];
            [config setAuthzModule:facebookAuthzModule];
        }];
    
    // set up our google pipeline and pipes
    _gPipeline = [AGPipeline pipelineWithBaseURL:[NSURL URLWithString:@"https://www.googleapis.com"]];
    
    [_gPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"googleUploadPipe"];
        [config setEndpoint:@"upload/drive/v2/files"];
        [config setAuthzModule:googleAuthzModule];
    }];
    
    [_gPipeline pipe:^(id<AGPipeConfig> config) {
        [config setName:@"googleMetaPipe"];
        [config setEndpoint:@"drive/v2/files"];
        [config setAuthzModule:googleAuthzModule];
    }];
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Google", nil];
    
    [actionSheet showInView:self.view];

}

#pragma mark - ActionSheet Actions

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Facebook"]) {
        [self shareWithFacebook];
    } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Google"]) {
        [self shareWithGoogleDrive];
    }
}

-(void)shareWithFacebook {
    id<AGPipe> fbUploadPipe = [_fbPipeline pipeWithName:@"facebookUploadPipe"];

    [self performUploadWithPipe:fbUploadPipe success:^(id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"Successfully uploaded!"];
    } failure:^(NSError *error) {
         [SVProgressHUD showErrorWithStatus:@"Failed to upload!"];
    }];
}

- (void)shareWithGoogleDrive {
    id<AGPipe> googleUploadPipe = [_gPipeline pipeWithName:@"googleUploadPipe"];
    
    [self performUploadWithPipe:googleUploadPipe success:^(id responseObject) {
         // time to set metadata
        
        // extract the "id" assigned from the response
        NSString *fileId = [responseObject objectForKey:@"id"];
        // set the filename
        NSDictionary *params = @{ @"id":fileId, @"title": self.imageView.accessibilityIdentifier};
        
        // set metadata
        id<AGPipe> googleMetaPipe = [_gPipeline pipeWithName:@"googleMetaPipe"];
        [googleMetaPipe save:params success:^(id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"Successfully uploaded!"];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Failed to set metadata!"];
        }];

    } failure:^(NSError *error) {
         [SVProgressHUD showErrorWithStatus:@"Failed to upload!"];
    }];
}

- (void)performUploadWithPipe:(id<AGPipe>)pipe
                      success:(void (^)(id responseObject))success
                      failure:(void (^)(NSError *error))failure {
    
    // extract the image filename
    NSString *filename = self.imageView.accessibilityIdentifier;
    
    // Get currently displayed image
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
    
    // set up payload with the image
    AGFileDataPart *dataPart = [[AGFileDataPart alloc] initWithFileData:imageData
                                                                   name:@"image"
                                                               fileName:filename
                                                               mimeType:@"image/jpeg"];
    NSDictionary *dict = @{@"data:": dataPart};
    
    // show a progress indicator
    [pipe setUploadProgressBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:(totalBytesSent/(float)totalBytesExpectedToSend) status:@"uploading, please wait"];
        });
    }];
    
    // upload file
    [pipe save:dict success:success failure:failure];
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
   [self setup:[[alertView textFieldAtIndex:0] text]];
}

#pragma mark - Utility methods
- (NSData *)salt {
    // retrieve or create salt
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *salt = [defaults objectForKey:kSalt];
    
    if (!salt) {
        salt = [AGRandomGenerator randomBytes];
        [defaults setObject:salt forKey:kSalt];
        [defaults synchronize];
    }
    
    return salt;
}

@end
