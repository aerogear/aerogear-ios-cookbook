//
//  AGAddPresentViewController.h
//  Xmas
//
//  Created by Corinne Krych on 11/21/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGAddPresentViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *toWhomTextField;
@property (weak, nonatomic) IBOutlet UITextView *description;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UISwitch *isSecret;
@end
