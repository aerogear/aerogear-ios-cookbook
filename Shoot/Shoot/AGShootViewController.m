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
static inline NSString * AFNounce() {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    return (NSString *)CFBridgingRelease(string);
}



-(void)upload:(id<AGAuthzModule>) authzModule {
    NSString* readGoogleDriveURL = @"https://www.googleapis.com/drive/v2";
    NSURL* serverURL = [NSURL URLWithString:readGoogleDriveURL];
    AGPipeline* googleDocuments = [AGPipeline pipelineWithBaseURL:serverURL];
    
    id<AGPipe> documents = [googleDocuments pipe:^(id<AGPipeConfig> config) {
        [config setName:@"files"];
        [config setAuthzModule:authzModule];
    }];
    
//    [documents read:^(id responseObject) {
//        _documents = [[self buildDocumentList:responseObject[0]] copy];
//        [self.tableView reloadData];
//    } failure:^(NSError *error) {
//        // when an error occurs... at least log it to the console..
//        NSLog(@"Read: An error occured! \n%@", error);
//    }];
}

- (IBAction)share:(id)sender {
    NSLog(@"Sharing...");
    
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
        [self upload:_restAuthzModule];
    } failure:^(NSError *error) {
    }];
    
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
