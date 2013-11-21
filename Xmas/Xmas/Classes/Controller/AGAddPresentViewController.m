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

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextField class]])
			[view resignFirstResponder];
	}
}

@end
