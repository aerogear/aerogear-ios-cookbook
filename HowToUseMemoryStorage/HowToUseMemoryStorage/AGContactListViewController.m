//
//  AGContactListViewController.m
//  HowToUseMemoryStorage
//
//  Created by Corinne Krych on 10/10/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGContactListViewController.h"
#import "AGContactItemViewController.h"

@implementation AGContactListViewController {
    NSMutableArray* _contacts;
    NSString* _currentContact;
}

- (IBAction)editButton:(UIBarButtonItem *)sender {
     [self setEditing:UITableViewCellEditingStyleDelete animated:NO];
}

@synthesize myTableView;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // Usually the number of items in your array (the one that holds your list)
    return [_contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //Where we configure the cell in each row
    
    static NSString *CellIdentifier = @"ContactCell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell... setting the text of our cell's label
    cell.textLabel.text = [_contacts objectAtIndex:indexPath.row];
    return cell;
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
	// Do any additional setup after loading the view.
    _contacts = [[NSMutableArray alloc] initWithArray:@[@"111-111-111", @"222-222-222"]];
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.myTableView reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [myTableView setEditing:editing animated:animated];
}

- (void)tableView: (UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath: (NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_contacts removeObjectAtIndex:[indexPath row]];
        [myTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self setEditing:NO animated:NO];
     }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AGContactItemViewController *detailController = segue.destinationViewController;
    NSString *contact = [_contacts objectAtIndex:self.myTableView.indexPathForSelectedRow.row];
    detailController.name = contact;
}
@end
