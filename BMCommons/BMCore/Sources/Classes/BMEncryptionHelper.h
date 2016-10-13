//
//  BMEncryptionHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 20/06/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMCoreObject.h>

/**
 Encryption utility methods.
 
 See also the Encryption category of NSData: NSData+Encryption.
 */
@interface BMEncryptionHelper : NSObject

/**
 Encrypts a string using AES256 by converting the encrypted data to BASE-64 encoding.
 */
+ (NSString *)encryptString:(NSString *)s withKey:(NSString *)key;

/**
 Decrypts encrypted data in BASE-64 encoding using AES256 by converting.
 */
+ (NSString *)decryptString:(NSString *)s withKey:(NSString *)key;

/**
 Calculates the MD5 digest of the file at the specified path in a streaming fashion, that is without loading all the data in memory at once.
 
 This is needed for large files such as videos.
 */
+ (NSData *)dataWithMD5DigestOfFileAtPath:(NSString *)filePath;

/**
 Hex-encoded string of the data returned by dataWithMD5DigestOfFileAtPath:.
 */
+ (NSString *)stringWithMD5DigestOfFileAtPath:(NSString *)filePath;

@end
