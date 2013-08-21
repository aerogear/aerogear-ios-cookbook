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

#import "AGLeadViewController.h"
#import "AGLead.h"
#import "AeroDocAPIClient.h"

@implementation AGLeadViewController {
    UILabel *_name;
    UILabel *_location;
    UILabel *_phoneNumber;
    UIButton *_accept;
    UIButton *_dismiss;
}

@synthesize lead = _lead;
@synthesize delegate;

#pragma mark - View lifecycle

- (void)viewDidUnload {
    [super viewDidUnload];
        
    DLog(@"AGTaskViewController viewDidUnLoad");
}

- (void)viewDidLoad {

    [super viewDidLoad];
    DLog(@"AGLeadViewController start viewDidLoad");
    self.view.backgroundColor = [UIColor clearColor];
    
    //UIColor *textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.0 alpha:1.0];
    
    _name = [[UILabel alloc] initWithFrame:CGRectMake(55, 100, 200, 32)];
    _name.backgroundColor = [UIColor clearColor];
    _name.font = [UIFont fontWithName:@"Arial" size:15];
    if (![self.lead.name isKindOfClass:[NSNull class]]) {
        _name.text = self.lead.name;
    }
    _location = [[UILabel alloc] initWithFrame:CGRectMake(55, 140, 200, 32)];
    _location.backgroundColor = [UIColor clearColor];
    //_location.textColor = textColor;
    if (![self.lead.location isKindOfClass:[NSNull class]]) {
        _location.text = self.lead.location;
    }

    _phoneNumber = [[UILabel alloc] initWithFrame:CGRectMake(55, 180, 200, 32)];
    _phoneNumber.backgroundColor = [UIColor clearColor];
    //_phoneNumber.textColor = textColor;
    if (![self.lead.phoneNumber isKindOfClass:[NSNull class]]) {
        _phoneNumber.text = [self.lead phoneNumber];
    }
    [self.view addSubview:_name];
    [self.view addSubview:_location];
    [self.view addSubview:_phoneNumber];
    
    _accept = [self buttonWithText:@"Accept"];
    _accept.frame = CGRectMake(55, 246, 200, 52);
    [_accept addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchDown];
    //_accept.titleLabel.textColor = textColor;
    
    _dismiss = [self buttonWithText:@"Dismiss"];
    _dismiss.frame = CGRectMake(55, 306, 200, 52);
    [_dismiss addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
    //_dismiss.titleLabel.textColor = textColor;
    
    [self.view addSubview:_accept];
    [self.view addSubview:_dismiss];
       
    DLog(@"AGLoginViewController end viewDidLoad");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(UIButton*) buttonWithText:(NSString*) text
{
    UIImage* buttonImage = [UIImage imageNamed:@"topAndBottomRow.png"];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonImage forState:UIControlStateSelected];
    
    return button;
}

#pragma mark - Action Methods

- (IBAction)accept {
    DLog(@"Lead accepted");
    self.lead.saleAgent = [[AeroDocAPIClient sharedInstance] userId];
    [delegate didAccept:self lead:self.lead];
    [self goBackToList];
}

- (IBAction)dismiss {
    DLog(@"Lead dismissed");
    [delegate didDismiss:self lead:self.lead];
    [self goBackToList];
}
- (void)goBackToList {   
    [self.navigationController popViewControllerAnimated:YES];
}
@end
