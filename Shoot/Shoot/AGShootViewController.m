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

#import "AGAppDelegate.h"


@interface AGShootViewController ()

@end

@implementation AGShootViewController {
    id<AGAuthzModule> _restAuthzModule;
}
@synthesize imageView = _imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) useCamera:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        _newMedia = YES;
    }
}

- (void) useCameraRoll:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
        _newMedia = NO;
    }
}

-(void)upload:(id<AGAuthzModule>) authzModule token:(NSString*)object{
    NSString* uploadGoogleDriveURL = @"https://www.googleapis.com/upload/drive/v2";
    NSURL* serverURL = [NSURL URLWithString:uploadGoogleDriveURL];
    
    AGPipeline* googleDocuments = [AGPipeline pipelineWithBaseURL:serverURL];
    
    id<AGPipe> pipe = [googleDocuments pipe:^(id<AGPipeConfig> config) {
        [config setName:@"files"];
        [config setAuthzModule:authzModule];
    }];
    // Get image with high compression
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
    AGFileDataPart *dataPart2 = [[AGFileDataPart alloc] initWithFileData:imageData
                                                                    name:@"image"
                                                                fileName:@"image.jpeg" mimeType:@"image/jpeg"];
    // set up payload
    NSDictionary *dict = @{@"data2:": dataPart2};
    [pipe save:dict success:^(id responseObject) {
        NSLog(@"Successfully uploaded!");
        
    } failure:^(NSError *error) {
        NSLog(@"An error has occured during upload! \n%@", error);
    }];
    
    
}

- (IBAction)share:(id)sender {
    NSLog(@"Sharing...");
    if (_imageView.image == nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Missing image!"
                              message: @"Please select an image before sharing it"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    } else {
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
        
        [_restAuthzModule requestAccessSuccess:^(id object) {
            [self upload:_restAuthzModule token:object];
        } failure:^(NSError *error) {
        }];
        
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        _imageView.image = image;
        if (_newMedia)
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
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

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
