//
//  AGBrowseViewController.h
//  Shoot
//
//  Created by Corinne Krych on 11/27/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface AGBrowseViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)useCameraRoll:(id)sender;
@end
