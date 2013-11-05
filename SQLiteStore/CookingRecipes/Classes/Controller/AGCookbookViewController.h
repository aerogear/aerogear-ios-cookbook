//
//  AGCookbookViewController.h
//  HowToUseSQLiteStorage
//
//  Created by Corinne Krych on 10/10/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGCookbookViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
