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
#import "AGAddRecipeViewController.h"
#import "AeroGear.h"



@implementation AGCookbookViewController {
    id<AGStore> _store;
}
@synthesize recipes =_recipes;
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString* type = @"SQLITE"; //@"PLIST";
    AGDataManager* dm = [AGDataManager manager];
    // Add a new (default) store object:
    _store = [dm store:^(id<AGStoreConfig> config) {
        [config setName:@"recipes"];
        [config setType:type];
    }];
    
    // When app is first launched read from bundle static file and store in PLIST or SQLITE store
    [self bootstrapDataFromFileName:@"recipes" toStore:_store];

    // Read from PLIST store and convert dictionary into array of AGRecipe
    _recipes = [[NSMutableArray alloc] init];
    NSArray* myRecipes = [_store readAll];
    for (id item in myRecipes) {
        AGRecipe *rec = [[AGRecipe alloc] initWithDictionary:item];
       [_recipes addObject:rec];
    }
}

/*
 If no file is found with name in Document folder, check bundle
 and if file found boostrap data into AGStore
 */
- (NSArray*) bootstrapDataFromFileName:(NSString*)name toStore:(id<AGStore>)store {
    
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath;
    
    if ([store.type isEqualToString:@"PLIST"]) {
        rootPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:name];
    } else if ([store.type isEqualToString:@"SQLITE"]) {
        rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:[name stringByAppendingString:@".sqlite3"]];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
        
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSArray *recipesList = (NSArray *)[NSPropertyListSerialization
                                    propertyListFromData:plistXML
                                    mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                    format:&format
                                    errorDescription:&errorDesc];
        if (!recipesList) {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }
        BOOL resp = [store save:recipesList error:nil];
        return recipesList;
    }
    return [[NSMutableArray alloc] init];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
         NSLog(@"Remove Recipe >>>>%d", [indexPath row]);
        [self removeRecipe:[self.recipes objectAtIndex:[indexPath row]] withIndex:[indexPath row]];
    }
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

- (void)addRecipe:(AGRecipe *)recipe {
    NSMutableDictionary *recipeDictionary = [recipe dictionary];
    [_store save:recipeDictionary error:nil];
    recipe.recipeId = recipeDictionary[@"id"];
    [self.recipes addObject:recipe];
    [self.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)removeRecipe:(AGRecipe *)recipe withIndex:(NSInteger)index{
    NSLog(@"Remove Recipe >>>>%@", recipe.recipeId);
    [_store remove:[recipe dictionary] error:nil];
    [self.recipes removeObjectAtIndex:index];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showRecipeDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        AGRecipeViewController *recipeViewController = segue.destinationViewController;
        recipeViewController.recipe = [_recipes objectAtIndex:indexPath.row];
    } else if ([segue.identifier isEqualToString:@"addRecipe"]) {
        AGAddRecipeViewController *addRecipeViewController = segue.destinationViewController;
        addRecipeViewController.delegate = self;
    }
}

@end
