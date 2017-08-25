//
//  NSData+AES256.h
//  BMCommons
//
//  Created by Werner Altewischer on 11/30/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Encryption helper methods as category on NSData.
 */
@interface NSData (BMEncryption)

/**
 Symmetrically encrypts this data using AES256 with the supplied encryption key.
 */
- (nullable NSData *)bmAES256EncryptedDataWithKey:(NSString *)key;

/**
 Symmetrically decrypts this data using AES256 with the supplied encryption key.
 */
- (nullable NSData *)bmAES256DecryptedDataWithKey:(NSString *)key;

/**
 Asymmetrically encrypts this data using the supplied public key reference.
 */
- (nullable NSData *)bmAsymmetricEncryptedDataWithKey:(SecKeyRef)keyRef;

/**
 Asymmetrically decrypts this data using the supplied private key reference.
 */
- (nullable NSData *)bmAsymmetricDecryptedDataWithKey:(SecKeyRef)keyRef;

/**
 Returns an NSData object containing the SHA1 digest of this data.
 */
- (nullable NSData *)bmDataWithSHA1Digest;

/**
 Returns an NSData object containing the SHA256 digest of this data.
 */
- (nullable NSData *)bmDataWithSHA256Digest;

/**
 Returns an NSData object containing the MD5 digest of this data.
 */
- (nullable NSData *)bmDataWithMD5Digest;

/**
 Returns a NSString object containing the SHA1 digest of this data.
 */
- (nullable NSString *)bmStringWithSHA1Digest;

/**
 Returns a NSString object containing the SHA256 digest of this data.
 */
- (nullable NSString *)bmStringWithSHA256Digest;

/**
 Returns an NSString object containing the MD5 digest of this data.
 */
- (nullable NSString *)bmStringWithMD5Digest;

/**
 Generates a signature of this data signed with the specified private key.
 
 @return NSData with the signature.
 */
- (nullable NSData *)bmSignatureWithKey:(SecKeyRef)keyRef;

/**
 Verifies the supplied signature using the specified public key.
 
 @return True if signature is valid, false otherwise.
 */
- (BOOL)bmVerifySignature:(NSData *)signature withKey:(SecKeyRef)keyRef;

@end

NS_ASSUME_NONNULL_END
