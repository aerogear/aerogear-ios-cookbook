Xmas
==============
Chrismas is coming - sooner or later :)

Let's help Santa Claus to keep his gifts list secure. We want to achieve local encryption of the present description but keep information like to whom the present is for, clear and searchable. Let's see how we encrypt some data into local storage.

Xmas app shows you how to use [aerogear-crypto-ios](https://github.com/aerogear/aerogear-crypto-ios). Using AeroGear crypto lib, you can easily do private key encryption (also called symmetric encryption).

## UI Fow 
As you can see in the storyboard, user start application with UICollectionView which list all presents. When the app is launched for the first time the list is empty.

## Encryption Flow
First of all, to encrypt your data you need an encryption key. Your key can be derived from a PIN, password or passphrase using [AGPBKDF2](http://aerogear.org/docs/specs/aerogear-crypto-ios/Classes/AGPBKDF2.html). 

    NSData *salt = [AGRandomGenerator randomBytes];
    NSData *encryptionKey = [pbkdf2 deriveKey:@"password4me" salt:salt];



For random generation of key, salt or IV, use link:http://aerogear.org/docs/specs/aerogear-crypto-ios/Classes/AGRandomGenerator.html[AGRandomGenerator]. By default, AGRandomGenerator generates 16 bytes key, but you can also specify the length if you wish.

Once you've got your encryption key, use link:http://aerogear.org/docs/specs/aerogear-crypto-ios/Classes/AGCryptoBox.html[AGCryptoBox] to do the actual encryption. Its interface is simple:

[source,c]
----

@interface AGCryptoBox : NSObject
- (id)initWithKey:(NSData*)key;¬
- (NSData*)encrypt:(NSData*)data IV:(NSData*)IV;
- (NSData*)decrypt:(NSData*)data IV:(NSData*)IV;
@end


----

With link:http://aerogear.org/docs/specs/aerogear-crypto-ios/Classes/AGCryptoBox.html[AGCryptoBox], you can encrypt/decrypt data using your encryption key and a randomly generated IV (Initialization Vector) as shown below:

[source,c]
----

    NSString* stringToEncrypt = @"I want to keep it secret";
    // encode string into data
    NSData* dataToEncrypt = [stringToEncrypt dataUsingEncoding:NSUTF8StringEncoding];
    NSData* IV = [AGRandomGenerator randomBytes:16];
    
    // encrypt
    NSData* encryptedData = [cryptoBox encrypt:dataToEncrypt IV:IV];
                
    // decrypt
    NSData* decryptedData = [cryptoBox decrypt:encryptedData IV:IV];


----

NOTE: To be able to decrypt, you need the randomly generated IV and you can regenerate the key with the salt and the password (prompted on the fly).
It is not recommended to store either password or derived key. Salt and IV are not security sensitive in the sense that they can be stored.


