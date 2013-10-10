//
//  AGContactListViewController.h
//  HowToUseMemoryStorage
//
//  Created by Corinne Krych on 10/10/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGContactListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@end
