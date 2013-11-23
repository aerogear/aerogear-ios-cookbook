Xmas
==============
Chrismas is coming - sooner or later :)

Let's help Santa Claus to keep his gifts list secure. We want to achieve local encryption of the present description but keep information like to whom the present is for, clear and searchable. Let's see how we encrypt some data into local storage.

Xmas app shows you how to use [aerogear-crypto-ios](https://github.com/aerogear/aerogear-crypto-ios). Using AeroGear crypto lib, you can easily do private key encryption (also called symmetric encryption).

## UI Fow 
When you start the application you will first see a collection list of cards (with ramdom xmas images on the back). If the app is launched for the first time the list is empty. 

To enter a new present, hit the plus sign on the top bar. You enter the name to whom the present is for, a description and your secure your present with a password. Once added, a new card is displayed in the collection view. To flip the card you will be pompted to enter your password. If you use a wrong password, the present description will not be displayed. you can encrypt each present with a different password if you wish but make sure you will remember it.

![Xmas app](https://github.com/corinnekrych/aerogear-ios-cookbook/raw/master/Xmas/Xmas/Resources/images/xmas-flow.png "xmas")

## Encryption Flow

### Derive Key from password
First of all, to encrypt your data you need an **encryption key**. Your key can be derived from your password using [AGPBKDF2](http://aerogear.org/docs/specs/aerogear-crypto-ios/Classes/AGPBKDF2.html). 

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

For random generation of key, salt or IV, use [AGRandomGenerator](http://aerogear.org/docs/specs/aerogear-crypto-ios/Classes/AGRandomGenerator.html). By default, AGRandomGenerator generates 16 bytes key, but you can also specify the length if you wish.

You need to store your **salt** to be able to regenerate the exact same key when you want to decript this description information. In this example, we've chosen to store this information in NSUserDefaults.

## Encrypt
Once you've got your encryption key, use [AGCryptoBox](http://aerogear.org/docs/specs/aerogear-crypto-ios/Classes/AGCryptoBox.html) to do the actual encryption.

With [AGCryptoBox](http://aerogear.org/docs/specs/aerogear-crypto-ios/Classes/AGCryptoBox.html), you can encrypt/decrypt data using your encryption key and a randomly generated IV (Initialization Vector) as shown below:

    // Use CryptoBox to encrypt/decrypt data
    AGCryptoBox* cryptoBox = [[AGCryptoBox alloc] initWithKey:key];
    
    // Get a random IV
    NSData* IV = [self getIV];
	    
    // transform string to data
    NSData* dataToEncrypt = [dataDict[@"description"] dataUsingEncoding:NSUTF8StringEncoding];

Same as for the salt, IV need to be store to be able to decrypt the encrypted data. This is what we're doing in getIV method:

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

Salt and IV are not security sensitive in the sense that they can be stored. Do not store password or encryption key.

## Decrypt

        // decrypt description
        NSData* key = [self getKeyFromPassword:_password];
        NSData* IV = [self getIV];
        AGCryptoBox* cryptoBox = [[AGCryptoBox alloc] initWithKey:key];
        NSMutableDictionary* gift = [_store read:_currentGiftId];
        NSString* decryptedDescription = [[NSString alloc] initWithData:[cryptoBox decrypt:gift[@"description"] IV:IV] encoding:NSUTF8StringEncoding];
        gift[@"description"] = decryptedDescription;
        [self.collectionView reloadData];

## Let's put it together

To encrypt data, look at the logic in [AGGiftListCollectionViewController](https://github.com/corinnekrych/aerogear-ios-cookbook/blob/master/Xmas/Xmas/Classes/Controller/AGGiftListCollectionViewController.m#L149)

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






NOTE: To be able to decrypt, you need the randomly generated IV and you can regenerate the key with the salt and the password (prompted on the fly).
It is not recommended to store either password or derived key. Salt and IV are not security sensitive in the sense that they can be stored.


