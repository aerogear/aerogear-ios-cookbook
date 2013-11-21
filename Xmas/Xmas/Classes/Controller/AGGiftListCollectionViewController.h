//
//  AGGiftListCollectionViewController.h
//  Xmas
//
//  Created by Corinne Krych on 11/19/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGGiftCellView.h"

@interface AGGiftListCollectionViewController : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate>


@property(nonatomic, strong) NSMutableArray* gifts;
@end
