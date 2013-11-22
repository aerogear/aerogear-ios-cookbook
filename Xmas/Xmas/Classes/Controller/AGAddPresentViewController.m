//
//  AGAddPresentViewController.m
//  Xmas
//
//  Created by Corinne Krych on 11/21/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGAddPresentViewController.h"


@implementation AGAddPresentViewController
@synthesize toWhomTextField;
@synthesize description;
@synthesize password;
@synthesize isSecret;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL) validate {
    if ([toWhomTextField.text length] != 0 &&
        [description.text length] !=0 &&
        [password.text length] != 0) {
        return YES;
    } else {
        toWhomTextField.layer.borderColor = [[UIColor redColor]CGColor];
        toWhomTextField.layer.borderWidth = 1.0;
        description.layer.borderColor = [[UIColor redColor]CGColor];
        description.layer.borderWidth = 1.0;
        password.layer.borderColor = [[UIColor redColor]CGColor];
        password.layer.borderWidth = 1.0;
        return NO;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return  [self validate];
}


@end
