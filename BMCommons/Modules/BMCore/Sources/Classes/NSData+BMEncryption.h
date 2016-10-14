//
//  NSData+AES256.h
//  BMCommons
//
//  Created by Werner Altewischer on 11/30/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Encryption helper methods as category on NSData.
 */
@interface NSData (BMEncryption)

/**
 Symmetrically encrypts this data using AES256 with the supplied encryption key.
 */
- (NSData *)bmAES256EncryptedDataWithKey:(NSString *)key;

/**
 Symmetrically decrypts this data using AES256 with the supplied encryption key.
 */
- (NSData *)bmAES256DecryptedDataWithKey:(NSString *)key;

/**
 Asymmetrically encrypts this data using the supplied public key reference.
 */
- (NSData *)bmAsymmetricEncryptedDataWithKey:(SecKeyRef)keyRef;

/**
 Asymmetrically decrypts this data using the supplied private key reference.
 */
- (NSData *)bmAsymmetricDecryptedDataWithKey:(SecKeyRef)keyRef;

/**
 Returns an NSData object containing the SHA1 digest of this data.
 */
- (NSData *)bmDataWithSHA1Digest;

/**
 Returns an NSData object containing the SHA256 digest of this data.
 */
- (NSData *)bmDataWithSHA256Digest;

/**
 Returns an NSData object containing the MD5 digest of this data.
 */
- (NSData *)bmDataWithMD5Digest;

/**
 Returns a NSString object containing the SHA1 digest of this data.
 */
- (NSString *)bmStringWithSHA1Digest;

/**
 Returns a NSString object containing the SHA256 digest of this data.
 */
- (NSString *)bmStringWithSHA256Digest;

/**
 Returns an NSString object containing the MD5 digest of this data.
 */
- (NSString *)bmStringWithMD5Digest;

/**
 Generates a signature of this data signed with the specified private key.
 
 @return NSData with the signature.
 */
- (NSData *)bmSignatureWithKey:(SecKeyRef)keyRef;

/**
 Verifies the supplied signature using the specified public key.
 
 @return True if signature is valid, false otherwise.
 */
- (BOOL)bmVerifySignature:(NSData *)signature withKey:(SecKeyRef)keyRef;

@end
