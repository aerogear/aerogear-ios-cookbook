Shoot'nShare
==============
You want to shoot cool photos and share them with friends using Flickr.
With ShootnShare you can take picture, browse your camera roll, pick a picture to share and share it!
Picture get uploaded in http://www.flickr.com/photos/, select your pictures set.

## Install
All our project require [CocoaPods](http://cocoapods.org/) for dependency management;

**Before**, you can run the apps, you need to run the following command:

    pod install

After that you just need to open the ```Shoot.xcworkspace``` file in XCode and you're all set.

## Dropbox setup

First of all, if you don't already have one, create a [Flickr account](http://www.flickr.com/services/).
Then sign up with your credentials and create an app.

### Create app
To get started with your Flick, open the [Explore -> App Garden](https://www.dropbox.com/developers/apps) menu. Choose the [Create an App](http://www.flickr.com/services/apps/create/) option and request an API.

Finally, choose a name for your app, whatever you want, it just has to be unique and enter a description. Once you've created you app, you will have a App key and App secret.

Keep them to configure your app

### Authorize Shoot'nShare app

In AGAppDelegate, replace FLICKR_API_KEY/FLICKR_API_SHARED_SECRET by you provide app key/app secret.

	#warning ENTER YOUR FLICKR API_KEY
	NSString* OBJECTIVE_FLICKR_SAMPLE_API_KEY = @"FLICKR_API_KEY";
	#warning ENTER YOUR FLICKR API_SHARED_SECRET
	NSString* OBJECTIVE_FLICKR_SAMPLE_API_SHARED_SECRET = @"FLICKR_API_SHARED_SECRET";

## UI Fow 
When you start the application you need to link your app with Flickr. Click on 'Link to Flickr' and enter your credentials. 

Once linked, you can shoot a photo and then upload it to Flickr. You can also browse existing photos, pick one and upload it to Dropbox.

## How does it work?

### Flickr authentication: an overview

AeroGear iOS libs don't provide OAuth2 adapter (not yet, to come soon see JIRA-...), we use a fork version of [ObjectiveFlickr](https://github.com/corinnekrych/objectiveflickr) as cocoapods dependecy. 

### upload file


