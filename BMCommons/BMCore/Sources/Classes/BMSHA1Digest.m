//
//  BMSHA1Digest.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/06/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "BMSHA1Digest.h"
#import <BMCommons/BMCore.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>

@implementation BMSHA1Digest {
    CC_SHA1_CTX _sha1Context;
}

- (NSUInteger)lengthForDigest {
    return CC_SHA1_DIGEST_LENGTH;
}

- (void)initDigest {
    CC_SHA1_Init(&_sha1Context);
}

- (void)updateDigestWithBytes:(const void *)bytes length:(NSUInteger)length {
    uint32_t ccLength = BMShortenUIntSafely(length, @"Length supplied is too big: exceeds 32 bit");
    CC_SHA1_Update(&_sha1Context, bytes, ccLength);
}

- (void)finalizeDigestWithResult:(unsigned char *)result {
    CC_SHA1_Final(result, &_sha1Context);
}

@end
