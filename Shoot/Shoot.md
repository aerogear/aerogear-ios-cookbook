Shoot'nShare
==============
You want to shoot cool photos and share them with friends using GoogleDrive.
With ShootnShare you can take picture, browse your camera roll, pick a picture to share and share it!
Picture get uploaded to your GoogleDrive.

## Install
All our project require [CocoaPods](http://cocoapods.org/) for dependency management;

**Before**, you can run the apps, you need to run the following command:

    pod install

After that you just need to open the ```Shoot.xcworkspace``` file in XCode and you're all set.

## Google setup (optional)

Similar setup than [GoogleDrive app](../GoogleDrive/GoogleDrive.md) please refer to its configuration section. 
NOTES: Google setup has already been done for ShootnShare app. You can use out of the box. If you want to create your own app, please follow set instructions.

## UI Fow 
When you start the application you can take picture or select one from your camera roll.

Once an image is selected, you can share it. Doing so, you trigger the OAuth2 authorization porcess. Once successfully authorized, your image will be uploaded.

![Shoot'nShare app](https://github.com/aerogear/aerogear-ios-cookbook/raw/master/Shoot/Shoot/Resources/shootupload.png "Shoot")

NOTES: Because this app uses your camera, you should run it on actual device. Running on simulator won't allow camera shoot.

## AeroGear upload

How does it work?

	-(void)upload:(id<AGAuthzModule>) authzModule token:(NSString*)object{
	    NSString* uploadGoogleDriveURL = @"https://www.googleapis.com/upload/drive/v2";
	    NSURL* serverURL = [NSURL URLWithString:uploadGoogleDriveURL];
	    
	    AGPipeline* googleDocuments = [AGPipeline pipelineWithBaseURL:serverURL];
	    
	    id<AGPipe> pipe = [googleDocuments pipe:^(id<AGPipeConfig> config) {
	        [config setName:@"files"];
	        [config setAuthzModule:authzModule];
	    }];
	    // Get image with high compression
	    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 0.2); // [1]
	    AGFileDataPart *dataPart = [[AGFileDataPart alloc] 
	    	initWithFileData:imageData
	        name:@"image"
	        fileName:@"image.jpeg" 
	        mimeType:@"image/jpeg"]; 						// [2]
	    // set up payload
	    NSDictionary *dict = @{@"data:": dataPart};
	    [pipe save:dict success:^(id responseObject) {		// [3]
	        NSLog(@"Successfully uploaded!");
	        
	    } failure:^(NSError *error) {
	        NSLog(@"An error has occured during upload! \n%@", error);
	    }];
	}

[1] you convert your image into binary format with a compression ratio (high compression of 0.2)


[2] you build the first part of the upload wrapped into a AGFileDataPart object


[3] you add it to the dictionnary object to save and very transparently you save your data within the pipe.