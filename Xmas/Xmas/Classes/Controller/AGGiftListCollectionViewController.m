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
    NSArray* _images;
    NSMutableArray* _isCellSelected;
    id<AGStore> _store;
    NSString* _password;
}

@synthesize gifts = _gifts;

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
    
    _gifts = [[_store readAll] mutableCopy];
    
	if (!_isCellSelected){
        _isCellSelected = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < [self.gifts count]; i++) {
        _isCellSelected[i] = [NSNumber numberWithBool:NO];
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
    _isCellSelected[row] = [NSNumber numberWithBool:YES];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Password needed" message:@"to access this information" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Password Entered...");
    _password = [[alertView textFieldAtIndex:0] text];
    // decrypt description
    NSData* key = [self getKeyFromPassword:_password];
    NSData* IV = [self getIV];
    AGCryptoBox* cryptoBox = [[AGCryptoBox alloc] initWithKey:key];
    NSMutableDictionary* gift = [_store read:_currentGiftId];
    NSString* decryptedDescription = [[NSString alloc] initWithData:[cryptoBox decrypt:gift[@"description"] IV:IV] encoding:NSUTF8StringEncoding];
    gift[@"description"] = decryptedDescription;
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {

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

-(void) saveAndEncryptData:(NSMutableDictionary*)dataDict withPassword:(NSString*)password {
    // Generate key from pasword
    NSData* key = [self getKeyFromPassword:password];
    
    // Use CryptoBox to encrypt/decrypt data
    AGCryptoBox* cryptoBox = [[AGCryptoBox alloc] initWithKey:key];
    
    // Get a random IV
    NSData* IV = [self getIV];
    
    // transform string to data
    NSData* dataToEncrypt = [dataDict[@"description"] dataUsingEncoding:NSUTF8StringEncoding];
    
    // encrypt data
    dataDict[@"description"] = [cryptoBox encrypt:dataToEncrypt IV:IV];
    
    // Store data with encrypted description
    [_store save:dataDict error:nil];
    [self.gifts addObject:dataDict];
}

-(NSData*) getKeyFromPassword:(NSString*)password {
    NSData* salt;
    AGPBKDF2* derivator = [[AGPBKDF2 alloc] init];
   
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"xmas.salt"] == nil) {
        salt = [AGRandomGenerator randomBytes];
        [defaults setObject:salt forKey:@"xmas.salt"];
        [defaults synchronize];
    } else {
        salt = [defaults objectForKey:@"xmas.salt"];
    }
    NSData* key = [derivator deriveKey:password salt:salt];
    
    return key;
}

-(NSData*) getIV {
    NSData* IV;
    // Store IV (needed to decrypt encrypted data)
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"xmas.IV"] == nil) {
        IV = [AGRandomGenerator randomBytes];
        [defaults setObject:IV forKey:@"xmas.IV"];
        [defaults synchronize];
    } else {
        IV =[defaults objectForKey:@"xmas.IV"];
    }
    return IV;
}

@end
