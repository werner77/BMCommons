//
//  BMEncryptionHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 20/06/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMEncryptionHelper.h"
#import "NSData+BMEncryption.h"
#import "BMEncodingHelper.h"
#import <CommonCrypto/CommonDigest.h>

#define FileHashDefaultChunkSizeForReadingData 4096

@implementation BMEncryptionHelper

+ (NSString *)encryptString:(NSString *)s withKey:(NSString *)key {
    NSData *d = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [d bmAES256EncryptedDataWithKey:key];
    return [BMEncodingHelper base64EncodedStringForData:encryptedData];
}

+ (NSString *)decryptString:(NSString *)s withKey:(NSString *)key {
    NSData *d = [BMEncodingHelper dataWithBase64EncodedString:s];    
    NSData *decryptedData = [d bmAES256DecryptedDataWithKey:key];
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

+ (NSData *)dataWithMD5DigestOfFileAtPath:(NSString *)filePath {
    unsigned char buffer[CC_MD5_DIGEST_LENGTH];
    calculateMD5HashWithPath((__bridge CFStringRef)filePath, 0, buffer);
    return [NSData dataWithBytes:buffer length:CC_MD5_DIGEST_LENGTH];
}

+ (NSString *)stringWithMD5DigestOfFileAtPath:(NSString *)filePath {
    return [BMEncodingHelper hexEncodedStringForData:[self dataWithMD5DigestOfFileAtPath:filePath]];
}

// Function
static BOOL calculateMD5HashWithPath(CFStringRef filePath,
                              size_t chunkSizeForReadingData,
                              unsigned char *outDigest) {
    
    BOOL result = NO;
    
    // Declare needed variables
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,
                      (const void *)buffer,
                      (CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    CC_MD5_Final(outDigest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    result = YES;
    
done:
    
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}


@end
