//
//  AGContactListViewController.m
//  HowToUseMemoryStorage
//
//  Created by Corinne Krych on 10/10/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGContactListViewController.h"
#import "AGContactItemViewController.h"

@implementation AGContactListViewController
@synthesize contacts = _contacts;

- (IBAction)editButton:(UIBarButtonItem *)sender {
     [self setEditing:UITableViewCellEditingStyleDelete animated:NO];
}

@synthesize myTableView;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // Usually the number of items in your array (the one that holds your list)
    return [self.contacts count];
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
    AGContactItem* item = [self.contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
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
    AGContactItem* item1 = [[AGContactItem alloc] initWithName:@"Corinne" andPhoneNumber:@"111-111-112"];
    AGContactItem* item2 = [[AGContactItem alloc] initWithName:@"Christos" andPhoneNumber:@"222-222-223"];
    self.contacts = [(NSMutableArray<AGContact>*)[NSMutableArray alloc] initWithArray:@[item1, item2]];
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
    NSIndexPath* row = self.myTableView.indexPathForSelectedRow;
    if (row != nil) {
        AGContactItem *contact = [_contacts objectAtIndex:row.row];
        detailController.contact = contact;
    } else {
        detailController.contact = [[AGContactItem alloc] initWithName:@"New contact" andPhoneNumber:@"000-000-000"];
    }

}
@end
