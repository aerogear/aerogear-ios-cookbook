//
//  AGGiftListCollectionViewController.m
//  Xmas
//
//  Created by Corinne Krych on 11/19/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGGiftListCollectionViewController.h"


@implementation AGGiftListCollectionViewController

@synthesize gifts;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.gifts = [@[@{@"redId": @1, @"description": @"Mikado", @"toWhom": @"Emily"}, @{@"redId": @2, @"description": @"Barbie", @"toWhom": @"Barbara"}] mutableCopy];
	// Do any additional setup after loading the view.
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
    
    UIImage *image;
    int row = [indexPath row];
    
    myCell.toWhomLabel.text = [gifts[row] objectForKey:@"toWhom"];
    
    return myCell;
}
@end
