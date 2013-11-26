Cooking Recipe
==============
This recipe cookbook app shows you how to use AGSore, we'll delve into SQLITE permanent storage in more details in this example. But you can easely switch to PLIST storage if you wish..


## Install
All our project require [CocoaPods](http://cocoapods.org/) for dependency management;

**Before**, you can run the apps, you need to run the following command:

    pod install

After that you just need to open the ```CookingRecipes.xcworkspace``` file in XCode and you're all set.

## UI Fow 
When you first launch the Recipes app, you will bootstrap data from plist property file into SQLlite database. Bootstrap file contains 4 recipes. On start, your database is filled with those 4 recipes. Recipes are displayed in a table view controller. You can add or delete recipes. 

To navigate from 'recipes list' to 'add new recipe', we use push segue. Once the recipe is saved, delegate protocol is called.

![Cooking app](https://github.com/corinnekrych/aerogear-ios-cookbook/raw/master/Recipes/CookingRecipes/Resources/images/recipes-flow.png "Cooking")

## Code Snippets 
Let's see how to use Store in AeroGear libraries.
### Create Store

In [AGCookbookViewController.m](https://github.com/corinnekrych/aerogear-ios-cookbook/blob/master/Recipe/CookingRecipes/Classes/Controller/AGCookbookViewController.m), we initialize either SQLITE or PLIST store via the DataManager:

    // parameter type is here to switch database type for your testing
    NSString* type = @"SQLITE"; //@"PLIST";
    // create datamanager
    AGDataManager* dm = [AGDataManager manager];
    // Add a new store object by passing a block with config
    _store = [dm store:^(id<AGStoreConfig> config) {
        [config setName:@"recipes"];
        [config setType:type];
    }];
    
In CookingRecipes, we initialized a SQLite store, you can choose to have a PLits implementation if you wish. Both types are permenent storage. If no type is defined, the default implementation is MEMORY.

### Save

We actually have two examples of saving in the data store. First, when boostrapping initial recipes:

    NSArray *recipesList = (NSArray *)[NSPropertyListSerialization
                          propertyListFromData:plistXML
                              mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                        format:&format
                              errorDescription:&errorDesc];
    if (!recipesList) {
    	NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    // save a list of item into data store
    BOOL resp = [store save:recipesList error:nil];

Here we read data from file and we save a list of item at once. And then, when creating a new recipe and saving it:

	- (void)addRecipe:(AGRecipe *)recipe {
	    // serialise model object into NSMutableDictionary
	    NSMutableDictionary *recipeDictionary = [recipe dictionary];
	    // save it to the store
	    [_store save:recipeDictionary error:nil];
	    // other tasks: like refresh table view 
	    ...
	}

### Delete

	- (void)removeRecipe:(AGRecipe *)recipe withIndex:(NSInteger)index{
	    // serialise model object into NSMutableDictionary
	    [_store remove:[recipe dictionary] error:nil];
	    // other tasks: like refresh table view 
	    ...
	}

### Checking database content

When running the app in the simulator you may want to check the content of the database. Go to ~/Library/Application Support/iPhone Simulator/versionX.X/Applications/Unique-number/Documents, you should see a recipes.sqlite3 file. You can use [SQLite commands](http://www.sqlite.org/sqlite.html) to query the database.

	sqlite3 recipes.sqlite3
	.tables
	select * from recipes;

