/**
 * JBoss, Home of Professional Open Source
 * Copyright Red Hat, Inc., and individual contributors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * 	http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AGGiftListCollectionViewController.h"
#import "AGAddPresentViewController.h"
#import <AeroGear/AeroGear.h>
#import <AeroGear-Crypto/AGSecretBox.h>
#import <AeroGear-Crypto/AGRandomGenerator.h>
#import <AeroGear-Crypto/AGPBKDF2.h>

@implementation AGGiftListCollectionViewController {
    NSString* _currentGiftId;
    int _currentRowSelected;
    NSArray* _images;
    NSMutableArray* _isCellSelected;
    id<AGStore> _store;
    NSString* _password;
    NSData *_salt;
    NSData *_nonce;
}

@synthesize gifts;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _images = @[@"Santa-icon.png", @"mistletoe-icon.png", @"snowman-icon.png", @"tree-icon.png", @"candycane-icon.png", @"gift-icon1.png"];
    
    // Initialize storage
    AGDataManager* dm = [AGDataManager manager];
    _store = [dm store:^(id<AGStoreConfig> config) {
        [config setName:@"xmas"];
        [config setType:@"PLIST"];
    }];
    
    self.gifts = [self deepMutableCopy:[_store readAll]];
    
	if (!_isCellSelected){
        _isCellSelected = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [self.gifts count]; i++) {
        _isCellSelected[i] = [NSNumber numberWithBool:NO];
    }
    // initialize crypto params;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _salt = [defaults objectForKey:@"xmas.salt"];
    _nonce = [defaults objectForKey:@"xmas.nonce"];
    
    if(!_salt) { // if first launch, initialize params for subsequent reads
        _salt = [AGRandomGenerator randomBytes];
        [defaults setObject:_salt forKey:@"xmas.salt"];
        [defaults synchronize];
    }
    if(!_nonce) { // if first lunch, initialize params for subsequent reads
        _nonce =  [AGRandomGenerator randomBytes:24];
        [defaults setObject:_nonce forKey:@"xmas.nonce"];
        [defaults synchronize];
    }
    
}

- (id)deepMutableCopy:(NSArray*) list {
    NSData *binData = [NSPropertyListSerialization dataWithPropertyList:list
                                                                 format:NSPropertyListBinaryFormat_v1_0
                                                                options:0
                                                                  error:nil];
    
    NSMutableArray* mutableArray = [NSPropertyListSerialization propertyListFromData:binData
                                                                    mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                              format:NULL
                                                                    errorDescription:nil];
    return mutableArray;
}

- (NSString*)randomImage {
    int i = arc4random() % [_images count];
    return [_images objectAtIndex:i];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return self.gifts.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AGGiftCellView *myCell = [collectionView
                              dequeueReusableCellWithReuseIdentifier:@"MyCell"
                              forIndexPath:indexPath];
    int row = [indexPath row];
    
    myCell.toWhomLabel.text = [self.gifts[row] objectForKey:@"toWhom"];
    if (_isCellSelected[row] == [NSNumber numberWithBool:YES]) {
        myCell.descriptionTextView.text = [self.gifts[row] objectForKey:@"description"];
        myCell.frontImageView.image = nil;
    } else {
        myCell.descriptionTextView.text = nil;
        myCell.frontImageView.image =  [UIImage imageNamed:[self randomImage]];
    }
    
    return myCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int row = [indexPath row];
    
    NSMutableDictionary* gift = self.gifts[row];
    _currentGiftId = gift[@"id"];
    _currentRowSelected = row;
    if (_isCellSelected[_currentRowSelected] == [NSNumber numberWithBool:NO]) {
        [self showAlert];
    }
}

- (void)showAlert {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Password needed" message:@"to access this information" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Password Entered...");
    _password = [[alertView textFieldAtIndex:0] text];
    if (_password == nil || [_password length] == 0) {
        
    } else {
        // decrypt description
        NSMutableDictionary* gift = [self getGiftwithId:_currentGiftId within:self.gifts];
        
        gift[@"description"] = [self decrypt:gift[@"description"]];
        _isCellSelected[_currentRowSelected] = [NSNumber numberWithBool:YES];
        _currentRowSelected = -1;
        
        [self.collectionView reloadData];
    }
}

-(NSMutableDictionary*) getGiftwithId:(NSString*)identifier within:(NSArray*)list {
    for (NSMutableDictionary* field in list) {
        if([identifier isEqual:field[@"id"]]) {
            return field;
        }
    }
    return nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"addPresent:"]) {
        
	}
}

-(IBAction)unwindToRootVC:(UIStoryboardSegue *)segue {
    AGAddPresentViewController* source = segue.sourceViewController;
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict[@"toWhom"] = source.toWhomTextField.text;
    dict[@"description"] = source.description.text;
    [self saveAndEncryptData:dict withPassword:source.password.text];
    [_isCellSelected addObject:[NSNumber numberWithBool:NO]];
    [self.collectionView reloadData];
}

#pragma mark - Encryption / Decryption

-(NSData*) getKeyFromPassword:(NSString*)password {
    AGPBKDF2* derivator = [[AGPBKDF2 alloc] init];
    
    return [derivator deriveKey:password salt:_salt];
}

-(void) saveAndEncryptData:(id)gift withPassword:password {
    // Generate key from pasword
    NSData* key = [self getKeyFromPassword:password];
    
    // Use AGSecretBox to encrypt/decrypt data
    AGSecretBox* secretBox = [[AGSecretBox alloc] initWithKey:key];
    
    // transform string to data
    NSData* dataToEncrypt = [gift[@"description"] dataUsingEncoding:NSUTF8StringEncoding];
    
    // encrypt data
    NSError *error;
    NSData *encryptedData = [secretBox encrypt:dataToEncrypt nonce:_nonce error:&error];
    
    if (error) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"An error has occured"
                                                          message:[error description]
                                                         delegate:nil
                                                cancelButtonTitle:@"Bummer!"
                                                otherButtonTitles:nil];
        
        [message show];
        
        return;
    }
    
    // Store data with encrypted description
    gift[@"description"] = encryptedData;
    [_store save:gift error:nil];
    
    [self.gifts addObject:gift];
}

-(NSString*)decrypt:(NSData*)data {
    NSData* key = [self getKeyFromPassword:_password];
    AGSecretBox* secretBox = [[AGSecretBox alloc] initWithKey:key];
    
    NSError *error;
    NSString *decryptedData = [[NSString alloc] initWithData:[secretBox decrypt:data nonce:_nonce error:&error] encoding:NSUTF8StringEncoding];
    
    if (error) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"An error has occured!"
                                                          message:[error description]
                                                         delegate:nil
                                                cancelButtonTitle:@"Bummer!"
                                                otherButtonTitles:nil];
        
        [message show];
        
        return @""; // return empty upon error
    }
    
    return decryptedData;
}

@end