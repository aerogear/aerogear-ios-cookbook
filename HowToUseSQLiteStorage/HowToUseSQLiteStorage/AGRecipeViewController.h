//
//  AGRecipeViewController.h
//  HowToUseSQLiteStorage
//
//  Created by Corinne Krych on 10/10/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGRecipeViewController : UIViewController
@property (nonatomic, strong) IBOutlet UILabel *recipeDescription;
@property (nonatomic, strong) NSString *recipeName;
@end
