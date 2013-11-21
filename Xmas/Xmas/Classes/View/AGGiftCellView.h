//
//  AGGiftCellView.h
//  Xmas
//
//  Created by Corinne Krych on 11/19/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGGiftCellView : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *toWhomLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *frontImageView;

@end
