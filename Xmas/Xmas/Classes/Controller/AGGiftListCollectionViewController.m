//
//  AGGiftListCollectionViewController.m
//  Xmas
//
//  Created by Corinne Krych on 11/19/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGGiftListCollectionViewController.h"
#import "AGAddPresentViewController.h"

@implementation AGGiftListCollectionViewController {
    NSUInteger _currentGiftId;
    NSArray* _images;
    NSMutableArray* _isCellSelected;
}

@synthesize gifts;


- (void)viewDidLoad
{
    [super viewDidLoad];
    _images = @[@"Santa-icon.png", @"mistletoe-icon.png", @"snowman-icon.png", @"tree-icon.png", @"candycane-icon.png", @"gift-icon1.png"];

    self.gifts = [@[[@{@"recId": @1, @"description": @"Mikado", @"toWhom": @"Emily"} mutableCopy], [@{@"recId": @2, @"description": @"Barbie", @"toWhom": @"Barbara"} mutableCopy], [@{@"recId": @3, @"description": @"Wii", @"toWhom": @"Julian"} mutableCopy], [@{@"recId": @4, @"description": @"playmobil", @"toWhom": @"Mittie"} mutableCopy], [@{@"recId": @5, @"description": @"batman", @"toWhom": @"Louis"} mutableCopy]] mutableCopy];
	if (!_isCellSelected){
        _isCellSelected = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [self.gifts count]; i++) {
        _isCellSelected[i] = [NSNumber numberWithBool:NO];
    }

}

- (NSString*)randomImage {
    int i = arc4random() % [_images count];
    return [_images objectAtIndex:i];
}

- (void)viewWillDisappear:(BOOL)animated:(BOOL)animated {
    for (int i = 0; i < [self.gifts count]; i++) {
        _isCellSelected[i] = [NSNumber numberWithBool:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return self.gifts.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AGGiftCellView *myCell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:@"MyCell"
                                    forIndexPath:indexPath];
    int row = [indexPath row];
    
    myCell.toWhomLabel.text = [gifts[row] objectForKey:@"toWhom"];
    if (_isCellSelected[row] == [NSNumber numberWithBool:YES]) {
        myCell.descriptionTextView.text = [gifts[row] objectForKey:@"description"];
        myCell.frontImageView.image = nil;
    } else {
        myCell.descriptionTextView.text = nil;
        myCell.frontImageView.image =  [UIImage imageNamed:[self randomImage]];
    }
    
    return myCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {


    int row = [indexPath row];
    
    NSMutableDictionary* gift = gifts[row];
    _currentGiftId = [gift[@"recId"] integerValue];
    _isCellSelected[row] = [NSNumber numberWithBool:YES];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Password needed" message:@"to access this information" delegate:self cancelButtonTitle:@"Hide" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);

    NSMutableDictionary* gift = [gifts objectAtIndex:[@"1" integerValue]];
    gift[@"toWhom"] = @"222";
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // prior to transition, assign delegates to
    // self so we can get notified
    
	if ([segue.identifier isEqualToString:@"addPresent:"]) {  // Add Screen
        UINavigationController *navigationController = segue.destinationViewController;
        AGAddPresentViewController *addPresentViewController = [[AGAddPresentViewController alloc] init];
		//addPresentViewController.delegate = self;
        
	}
}

-(IBAction)unwindToRootVC:(UIStoryboardSegue *)segue {
    // Nothing needed here.
    AGAddPresentViewController* source = segue.sourceViewController;
    source.toWhomTextField;
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict[@"recId"] = @40;
    dict[@"toWhom"] = source.toWhomTextField.text;
    dict[@"description"] = source.description.text;
    [gifts addObject:dict];
    [_isCellSelected addObject:[NSNumber numberWithBool:NO]];
    [self.collectionView reloadData];
}

@end
