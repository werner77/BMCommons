//
//  BMKeychainUtil.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/10/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreObject.h>

/**
 Helper methods which use the iOS Security framework.
 */
@interface BMSecurityHelper : BMCoreObject {
    
}

/**
 Imports data from the specified p12 file into the keychain using the specified password.
 
 @param filePath The path to the file containing the p12 private key data
 @param password The password to use to open the encrypted file
 @return An NSData object representing a persistent ref to the item that may be used subsequently to retrieve the security identity from the keychain.
 @see newIdentityForPersistentRef:
 */
+ (NSData *)importP12DataFromFile:(NSString *)filePath usingPassword:(NSString *)password withError:(NSError **)error;

/**
 Retrieves and creates a new security identity using the specified persistent reference.
 
 @param NSData object containing a persistent reference to a keychain item.
 @return A reference to the found security entity or nil if not found. The caller is responsible for releasing the returned reference using CFRelease.
 */
+ (SecIdentityRef)newIdentityForPersistentRef:(NSData *)ref;

/**
 Creates a new certificate by importing the data from the specified file. 
 
 Returns nil in case of error.
 
 @param filePath The file path to the certificate file in DER format.
 @param error Pointer to the an error object which will be filled in case an error occured.
 @return The reference to the certificate or nil if an error occured. The caller is responsible for releasing the returned reference using CFRelease.
 */
+ (SecCertificateRef)newCertificateByImportingFromFile:(NSString *)filePath withError:(NSError **)error;

/**
 Copies the certificate from the supplied identity reference.
 
 @param identity Reference to a security identity.
 @return The reference to the certificate. The caller is responsible for releasing the returned reference using CFRelease.
 */
+ (SecCertificateRef)copyCertificateFromIdentity:(SecIdentityRef)identity;

/**
 Wipes all the data from the keychain for the current app.
 */
+ (void)wipeKeychain;

/**
 Generates a new keypair and adds it to the keychain. 
 
 The new keys are returned to the supplied pointers. It is the responsibility of the caller to call CFRelease on the returned keys when done.
 
 @param keySize Size in bits of the keys to generate which must be 512, 1024 or 2048.
 @param publicKeyTag Tag for the public key to be able to find it by in the keychain later.
 @param privateKeyTag Tag for the private key to be able to find it by in the keychain later.
 @param publicKey Contains a reference to the public key if the method returns succesfully. The caller is responsible for releasing the reference using CFRelease.
 @param privateKey Contains a reference to the private key if the method returns successfully. The caller is responsible for releasing the reference using CFRelease.
 @return The OSStatus code which is noErr upon succes or an error code upon failure.
 */
#if TARGET_OS_IPHONE
+ (OSStatus)generateKeyPairWithKeySize:(NSUInteger)keySize publicKeyTag:(NSString *)publicKeyTag privateKeyTag:(NSString *)privateKeyTag newPublicKey:(SecKeyRef *)publicKey newPrivateKey:(SecKeyRef *)privateKey;
#endif

/**
 Reads a certificate file in DER format containing a public key and returns a reference to this key if found.
 
 @param data The certificate data
 @return A reference to the public key upon success. The caller is responsible for releasing the reference using CFRelease.
 */
+ (SecKeyRef)newPublicKeyRefFromData:(NSData *)data;

/**
 Reads private key data in p12 format using the supplied password and returns a reference to the key if successful.
 
 @param password The password for the p12 data
 @param data The p12 data
 @return A reference to the private key if succesful. The caller is responsible for releasing the reference using CFRelease.
 */
+ (SecKeyRef)newPrivateKeyRefWithPassword:(NSString *)password fromData:(NSData *)data;

@end
