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

#import "AGCookbookViewController.h"
#import "AGRecipeViewController.h"
#import "AGRecipe.h"

@interface AGCookbookViewController ()

@end

@implementation AGCookbookViewController {
    NSArray* _recipes;
}

@synthesize tableView;

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
    NSMutableString *recipeWriting = [[NSMutableString alloc] init];
    [recipeWriting appendString:@"300g plain flour\n"];
    [recipeWriting appendString:@"200g unsalted butter\n"];
    [recipeWriting appendString:@"Knob of butter for greasing\n"];
    [recipeWriting appendString:@"450g apples, peeled, cored and cut into pieces\n"];
    [recipeWriting appendString:@"1. Preheat the oven to 180C\n"];
    [recipeWriting appendString:@"2. Place the flour and sugar in a large bowl and mix well. Taking a few cubes of butter at a time rub into the flour mixture. Keep rubbing until the mixture resembles breadcrumbs."];
    AGRecipe *ratatouille = [[AGRecipe alloc] initWithTitle:@"Ratatouille" andDescription:recipeWriting];
    AGRecipe *crumble = [[AGRecipe alloc] initWithTitle:@"Crumble" andDescription:recipeWriting];

    AGRecipe *applePie = [[AGRecipe alloc] initWithTitle:@"Apple Pie" andDescription:recipeWriting];
    AGRecipe *spinachCheeseManicotti = [[AGRecipe alloc] initWithTitle:@"Spinach & Cheese Manicotti" andDescription:recipeWriting];
    
	_recipes = @[ratatouille, crumble, applePie, spinachCheeseManicotti];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_recipes count];
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"RecipeCell";
    
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [[_recipes objectAtIndex:indexPath.row] recipeTitle];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showRecipeDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        AGRecipeViewController *recipeViewController = segue.destinationViewController;
        recipeViewController.recipe = [_recipes objectAtIndex:indexPath.row];
    }
}

@end
