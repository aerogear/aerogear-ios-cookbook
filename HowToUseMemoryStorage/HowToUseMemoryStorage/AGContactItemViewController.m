//
//  AGContactItemViewController.m
//  HowToUseMemoryStorage
//
//  Created by Corinne Krych on 10/10/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGContactItemViewController.h"
#import "AGContactListViewController.h"

@implementation AGContactItemViewController {

}

@synthesize contact = _contact;
@synthesize nameInput;
@synthesize phoneNumberLabel;

- (IBAction)saveContactItem:(UIButton *)sender {
    
}

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
	self.nameInput.text = self.contact.name;
    self.phoneNumberLabel.text = self.contact.phoneNumber;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event {
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextField class]])
			[view resignFirstResponder];
	}
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{ 
//}


@end
