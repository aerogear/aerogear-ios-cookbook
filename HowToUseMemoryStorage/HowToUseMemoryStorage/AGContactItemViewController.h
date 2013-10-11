//
//  AGContactItemViewController.h
//  HowToUseMemoryStorage
//
//  Created by Corinne Krych on 10/10/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGContactItemViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic) NSString* phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@end
