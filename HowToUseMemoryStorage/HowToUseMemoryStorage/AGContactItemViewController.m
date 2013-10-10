//
//  AGContactItemViewController.m
//  HowToUseMemoryStorage
//
//  Created by Corinne Krych on 10/10/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGContactItemViewController.h"


@implementation AGContactItemViewController {

}

@synthesize name;
@synthesize phoneNumber;
@synthesize nameLabel;
@synthesize phoneNumberLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.nameLabel.text = self.name;
    self.phoneNumberLabel.text = self.phoneNumber;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
