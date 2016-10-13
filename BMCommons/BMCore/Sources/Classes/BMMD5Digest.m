//
//  BMMD5Digest.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/06/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "BMMD5Digest.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>
#import <BMCore/BMCore.h>

@implementation BMMD5Digest {
    CC_MD5_CTX _md5Context;
}

- (NSUInteger)lengthForDigest {
    return CC_MD5_DIGEST_LENGTH;
}

- (void)initDigest {
    CC_MD5_Init(&_md5Context);
}

- (void)updateDigestWithBytes:(const void *)bytes length:(NSUInteger)length {
    CC_MD5_Update(&_md5Context, bytes, BMShortenUIntSafely(length, nil));
}

- (void)finalizeDigestWithResult:(unsigned char *)result {
    CC_MD5_Final(result, &_md5Context);
}

@end
