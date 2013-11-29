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
#import "AGAuthenticationModule.h"
#import "AGAppDelegate.h"
#import "AGOAuth1Configuration.h"

NSString *kFetchRequestTokenStep = @"kFetchRequestTokenStep";
NSString *kGetUserInfoStep = @"kGetUserInfoStep";

@interface AGShootViewController ()

@end

@implementation AGShootViewController
@synthesize imageView = _imageView;
@synthesize flickrClient = _flickrClient;
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
- (NSDictionary *)generateOAuthParametersWithToken:(AFOAuth1Token*)token {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"oauth_version"] = @"1.0";
    parameters[@"oauth_signature_method"] = @"HMAC-SHA1";
    parameters[@"oauth_consumer_key"] = FLICKR_SAMPLE_API_KEY;
    parameters[@"oauth_timestamp"] = [@(floor([[NSDate date] timeIntervalSince1970])) stringValue];
    parameters[@"oauth_nonce"] = AFNounce();
    parameters[@"is_public"] = @"0";
    parameters[@"oauth_token"] = token.key;
    
    return parameters;
}

- (IBAction)share:(id)sender {
    NSLog(@"Sharing...");
   
//    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.2);
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"tempImage.jpeg"]; //Add the file name
//    [imageData writeToFile:filePath atomically:YES]; //Write the file
//    NSURL *file1 = [NSURL fileURLWithPath:filePath];
    
    AGAuthenticator* authenticator = [AGAuthenticator authenticator];
    id<AGOAuth1Config> config = [[AGOAuth1Configuration alloc] init];
    [config setName:@"restAuthMod"];
    [config setType:@"AG_OAUTH1"];
    [config setKey:FLICKR_SAMPLE_API_KEY];
    [config setSecret:FLICKR_SAMPLE_API_SHARED_SECRET];
    [config setRequestTokenEndpoint:@"/services/oauth/request_token"];
    [config setAuthEndpoint:@"/services/oauth/authorize"];
    [config setCallbackAuthEndpoint:@"shootnshare://auth"];
    [config setAccessTokenEndpoint:@"/services/oauth/access_token"];
    [config setBaseURL:[NSURL URLWithString:@"http://www.flickr.com/"]];
    
    id<AGBaseAuthenticationModule> myOAuthModule = [authenticator auth:config];
    
    id<AGOAuth1AuthenticationModule> myOAuth1Module = (id<AGOAuth1AuthenticationModule>)myOAuthModule;
    [myOAuth1Module authorize:nil success:^(id token, id object) {
        NSLog(@"Success: Logged ");
        // construct the data to sent with the files added
//        NSDictionary *parameters = [self generateOAuthParametersWithToken:(AFOAuth1Token *)token];
//        NSMutableDictionary *files = [[NSMutableDictionary alloc] init];
//        [files addEntriesFromDictionary:parameters];
//        [files addEntriesFromDictionary:@{@"photo":file1}];
//        
//        
//        
//        AGPipeline* pipeline = [AGPipeline pipelineWithBaseURL:[NSURL URLWithString:@"http://api.flickr.com"]];
//        id<AGPipe> photos = [pipeline pipe:^(id<AGPipeConfig> config) {
//            
//            [config setName:@"upload"];
//            [config setBaseURL:[NSURL URLWithString:@"http://api.flickr.com"]];
//            [config setEndpoint:@"/services/upload/"];
//            [config setAuthModule:myOAuth1Module];
//
//        }];
//        
//        // save the 'new' project:
//        [photos save:files success:^(id responseObject) {
//             // LOG the JSON response, returned from the server:
//             NSLog(@"CREATE RESPONSE\n%@", [responseObject description]);
//         } failure:^(NSError *error) {
//             // when an error occurs... at least log it to the console..
//             NSLog(@"SAVE: An error occured! \n%@", error);
//         }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"Failure to OAuth1 authorize");
    }];









//    self.flickrClient = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.flickr.com/"] key:FLICKR_SAMPLE_API_KEY secret:FLICKR_SAMPLE_API_SHARED_SECRET];
//    
//
//    
//    [self.flickrClient authorizeUsingOAuthWithRequestTokenPath:@"/services/oauth/request_token" userAuthorizationPath:@"/services/oauth/authorize" callbackURL:[NSURL URLWithString:@"shootnshare://auth"] accessTokenPath:@"/services/oauth/access_token" accessMethod:@"POST" scope:nil success:^(AFOAuth1Token *accessToken, id responseObject) {
//        //[self.flickrClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
//        NSLog(@"Success: %@ Logged ", accessToken.userInfo[@"fullname"]);
//        [AFOAuth1Token storeCredential:accessToken withIdentifier:@"shootnshare"];
//        
//        NSDictionary *parameters = [self generateOAuthParametersWithToken:accessToken];
//        
//        // construct the data to sent with the files added
//        NSMutableDictionary *files = [[NSMutableDictionary alloc] init];
//        [files addEntriesFromDictionary:parameters];
//        [files addEntriesFromDictionary:@{@"photo":file1}];
//        
//        // Upload with AEroGEar failing with 401
//        AGPipeline* pipeline = [AGPipeline pipelineWithBaseURL:[NSURL URLWithString:@"http://api.flickr.com"]];
//        
//        id<AGPipe> photos = [pipeline pipe:^(id<AGPipeConfig> config) {
//            [config setName:@"upload"];
//            [config setBaseURL:[NSURL URLWithString:@"http://api.flickr.com"]];
//            [config setEndpoint:@"/services/upload/"];
//        }];
//        
//        
//        // save the 'new' project:
//        [photos save:files success:^(id responseObject) {
//            // LOG the JSON response, returned from the server:
//            NSLog(@"CREATE RESPONSE\n%@", [responseObject description]);
//            
//        } failure:^(NSError *error) {
//            // when an error occurs... at least log it to the console..
//            NSLog(@"SAVE: An error occured! \n%@", error);
//        }];
//
//
//    } failure:^(NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    

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
