//
//  AGGiftListCollectionViewController.m
//  Xmas
//
//  Created by Corinne Krych on 11/19/13.
//  Copyright (c) 2013 AeroGear. All rights reserved.
//

#import "AGGiftListCollectionViewController.h"
#import "AGAddPresentViewController.h"
#import "AeroGear.h"
#import "AeroGearCrypto.h"

@implementation AGGiftListCollectionViewController {
    NSString* _currentGiftId;
    int _currentRowSelected;
    NSArray* _images;
    NSMutableArray* _isCellSelected;
    id<AGStore> _store;
    NSString* _password;
    NSData *_salt;
    NSData *_IV;
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

    self.gifts = [[_store readAll] mutableCopy];
    
	if (!_isCellSelected){
        _isCellSelected = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [self.gifts count]; i++) {
        _isCellSelected[i] = [NSNumber numberWithBool:NO];
    }
    // initialize crypto params;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _salt = [defaults objectForKey:@"xmas.salt"];
    _IV = [defaults objectForKey:@"xmas.iv"];
    
    if(!_salt) { // if first launch, initialize params for subsequent reads
        _salt = [AGRandomGenerator randomBytes];
        [defaults setObject:_salt forKey:@"xmas.salt"];
        [defaults synchronize];
    }
    if(!_IV) { // if first lunch, initialize params for subsequent reads
        _IV =  [AGRandomGenerator randomBytes];
        [defaults setObject:_IV forKey:@"xmas.iv"];
        [defaults synchronize];
    }

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
        NSMutableDictionary* gift = [_store read:_currentGiftId];
        gift[@"description"] = [self decrypt:gift[@"description"]];
        _isCellSelected[_currentRowSelected] = [NSNumber numberWithBool:YES];
        _currentRowSelected = -1;
        
        [self.collectionView reloadData];
    }
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
    
    // Use CryptoBox to encrypt/decrypt data
    AGCryptoBox* cryptoBox = [[AGCryptoBox alloc] initWithKey:key];
    
    // transform string to data
    NSData* dataToEncrypt = [gift[@"description"] dataUsingEncoding:NSUTF8StringEncoding];
    
    // encrypt data
    gift[@"description"] = [cryptoBox encrypt:dataToEncrypt IV:_IV];
    
    // Store data with encrypted description
    [_store save:gift error:nil];
    
    [self.gifts addObject:gift];
}

-(NSString*)decrypt:(NSData*)data {
    NSData* key = [self getKeyFromPassword:_password];
    AGCryptoBox* cryptoBox = [[AGCryptoBox alloc] initWithKey:key];
    
    return [[NSString alloc] initWithData:[cryptoBox decrypt:data IV:_IV] encoding:NSUTF8StringEncoding];
}

@end
