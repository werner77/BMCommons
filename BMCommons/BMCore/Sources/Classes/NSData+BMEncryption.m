//
//  NSDate+AES256.m
//  BMCommons
//
//  Created by iphone developper on 11/30/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>
#import "NSData+BMEncryption.h"
#import <BMCommons/BMEncodingHelper.h>
#import <BMCommons/BMDigest.h>
#import <BMCommons/BMLogging.h>

@implementation NSData (BMEncryption)

#if !TARGET_OS_IPHONE
OSStatus SecKeyEncrypt(
                       SecKeyRef           key,
                       SecPadding          padding,
                       const uint8_t		*plainText,
                       size_t              plainTextLen,
                       uint8_t             *cipherText,
                       size_t              *cipherTextLen);

OSStatus SecKeyDecrypt(
                       SecKeyRef           key,
                       SecPadding          padding,
                       const uint8_t       *cipherText,
                       size_t              cipherTextLen,
                       uint8_t             *plainText,	
                       size_t              *plainTextLen);
#endif

- (NSData *)bmAES256EncryptedDataWithKey:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode,
										  keyPtr, kCCKeySizeAES256,
										  NULL /* initialization vector (optional) */,
										  [self bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}


- (NSData *)bmAES256DecryptedDataWithKey:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode,
										  keyPtr, kCCKeySizeAES256,
										  NULL /* initialization vector (optional) */,
										  [self bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}

- (NSData *)bmAsymmetricEncryptedDataWithKey:(SecKeyRef)keyRef {
    
    if (keyRef == NULL) {
        return nil;
    }
    
    size_t maxLength = SecKeyGetBlockSize(keyRef) - 11;
    
    if ([self length] > maxLength) {
        NSString *reason = [NSString stringWithFormat:@"Data is too long to encrypt with this key, max length is %ld and actual length is %ld", maxLength, (unsigned long)[self length]];
        NSException *ex = [NSException exceptionWithName:@"BMInvalidArgumentException" reason:reason userInfo:nil];
        @throw ex;
    }
    
    OSStatus status = noErr;
    
    uint8_t *plainBuffer = (uint8_t *)[self bytes];
    size_t plainBufferSize = [self length];
    size_t cipherBufferSize = SecKeyGetBlockSize(keyRef);
    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    
    //  Error handling
    // Encrypt using the public.
   status = SecKeyEncrypt(keyRef,
                           kSecPaddingPKCS1,
                           plainBuffer,
                           plainBufferSize,
                           &cipherBuffer[0],
                           &cipherBufferSize
                           );
    
    if (status == noErr) {
        return [NSData dataWithBytesNoCopy:cipherBuffer length:cipherBufferSize freeWhenDone:YES];
    }
    
    free(cipherBuffer);
    return nil;
}

- (NSData *)bmAsymmetricDecryptedDataWithKey:(SecKeyRef)keyRef {
    
    if (keyRef == NULL) {
        return nil;
    }
    
    OSStatus status = noErr;
    
    uint8_t *cipherBuffer = (uint8_t *)[self bytes];
    size_t cipherBufferSize = [self length];
    
    size_t plainBufferSize = SecKeyGetBlockSize(keyRef);
    uint8_t *plainBuffer = malloc(plainBufferSize * sizeof(uint8_t));
    
    //  Error handling
    status = SecKeyDecrypt(keyRef,
                           kSecPaddingPKCS1,
                           &cipherBuffer[0],
                           cipherBufferSize,
                           &plainBuffer[0],
                           &plainBufferSize
                           );
    
    if (status == noErr) {
        return [NSData dataWithBytesNoCopy:plainBuffer length:plainBufferSize freeWhenDone:YES];
    }
    
    free(plainBuffer);
    return nil;
}

- (NSData *)bmDataWithSHA1Digest {
    BMDigest *digest = [BMDigest digestOfType:BMDigestTypeSHA1];
    [digest updateWithData:self last:YES];
    return [digest dataRepresentation];
}

- (NSData *)bmDataWithSHA256Digest {
    BMDigest *digest = [BMDigest digestOfType:BMDigestTypeSHA256];
    [digest updateWithData:self last:YES];
    return [digest dataRepresentation];
}

- (NSString *)stringFromDigest:(NSData *)digest {
    return [BMEncodingHelper hexEncodedStringForData:digest];
}

- (NSString *)bmStringWithSHA1Digest {
    return [self stringFromDigest:[self bmDataWithSHA1Digest]];
}

- (NSString *)bmStringWithSHA256Digest {
    return [self stringFromDigest:[self bmDataWithSHA256Digest]];
}

- (NSString *)bmStringWithMD5Digest {
    return [self stringFromDigest:[self bmDataWithMD5Digest]];
}

- (NSData *)bmDataWithMD5Digest {
    BMDigest *digest = [BMDigest digestOfType:BMDigestTypeMD5];
    [digest updateWithData:self last:YES];
    return [digest dataRepresentation];
}

- (NSData *)bmSignatureWithKey:(SecKeyRef)keyRef {
    
    if (keyRef == NULL) {
        return nil;
    }
    
    NSData *sha1Digest = [self bmDataWithSHA1Digest];
    
    size_t maxLength = SecKeyGetBlockSize(keyRef) - 11;
    
    if ([sha1Digest length] > maxLength) {
        NSString *reason = [NSString stringWithFormat:@"Digest is too long to sign with this key, max length is %ld and actual length is %ld", maxLength, (unsigned long)[self length]];
        NSException *ex = [NSException exceptionWithName:@"BMInvalidArgumentException" reason:reason userInfo:nil];
        @throw ex;
    }
  
#if TARGET_OS_IPHONE
    OSStatus status = noErr;
    
    uint8_t *plainBuffer = (uint8_t *)[sha1Digest bytes];
    size_t plainBufferSize = [sha1Digest length];
    size_t cipherBufferSize = SecKeyGetBlockSize(keyRef);
    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    
    status = SecKeyRawSign(keyRef,
                           kSecPaddingPKCS1SHA1,
                           plainBuffer,
                           plainBufferSize,
                           &cipherBuffer[0],
                           &cipherBufferSize
                           );
    
    if (status == noErr) {
        return [NSData dataWithBytesNoCopy:cipherBuffer length:cipherBufferSize freeWhenDone:YES];
    }
    
    free(cipherBuffer);
    return nil;
#else
    CFErrorRef error = NULL;
    SecTransformRef signer = NULL;
    CFTypeRef signature = NULL;
    if ((signer = SecSignTransformCreate(keyRef, &error))) {
        
        if (SecTransformSetAttribute(signer, kSecInputIsAttributeName, kSecInputIsDigest, &error)) {
            if (SecTransformSetAttribute(signer,
                                         kSecTransformInputAttributeName,
                                         (__bridge CFDataRef)sha1Digest,
                                         &error)) {
                
                signature = SecTransformExecute(signer, &error);
            }
        }
    }
    
    if (error) {
        LogWarn(@"Could not sign: %@", error);
        CFRelease(error);
    }
    
    if (signer) {
        CFRelease(signer);
    }
    
    if (signature) {
        NSData *data = [NSData dataWithData:(__bridge NSData *)signature];
        CFRelease(signature);
        return data;
    } else {
        return nil;
    }
    
#endif
    
}

- (BOOL)bmVerifySignature:(NSData *)signature withKey:(SecKeyRef)keyRef {
    
    if (keyRef == NULL) {
        return NO;
    }
    
    NSData *sha1Digest = [self bmDataWithSHA1Digest];
        
#if TARGET_OS_IPHONE
    uint8_t *cipherBuffer = (uint8_t *)[sha1Digest bytes];
    size_t cipherBufferSize = [sha1Digest length];
    
    OSStatus sanityCheck = SecKeyRawVerify(keyRef,
                                           kSecPaddingPKCS1SHA1,
                                           &cipherBuffer[0],
                                           cipherBufferSize,
                                           (const uint8_t *)[signature bytes],
                                           [signature length]);
    
    return (sanityCheck == noErr);
#else
    BOOL valid = NO;
    CFErrorRef error = NULL;
    SecTransformRef verifier = SecVerifyTransformCreate(keyRef, (__bridge CFDataRef)signature, &error);
    
    if (verifier) {
        if (SecTransformSetAttribute(verifier, kSecInputIsAttributeName, kSecInputIsDigest, &error)) {
            if (SecTransformSetAttribute(verifier,
                                     kSecTransformInputAttributeName,
                                     (__bridge CFDataRef)sha1Digest,
                                         &error)) {
                CFTypeRef result = SecTransformExecute(verifier, &error);
                valid = (result == kCFBooleanTrue);
            }
        }
    }
    
    if (error) {
        LogWarn(@"Error when verifying signature: %@", error);
        CFRelease(error);
    }
    
    if (verifier) {
        CFRelease(verifier);
    }

    return valid;
    
#endif
}

@end
