//
// Created by Werner Altewischer on 22/12/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "BMSHA256Digest.h"
#import <BMCore/BMCore.h>

@implementation BMSHA256Digest {
    CC_SHA256_CTX _sha256Context;
}

- (NSUInteger)lengthForDigest {
    return CC_SHA256_DIGEST_LENGTH;
}

- (void)initDigest {
    CC_SHA256_Init(&_sha256Context);
}

- (void)updateDigestWithBytes:(const void *)bytes length:(NSUInteger)length {
    CC_SHA256_Update(&_sha256Context, bytes, BMShortenUIntSafely(length, nil));
}

- (void)finalizeDigestWithResult:(unsigned char *)result {
    CC_SHA256_Final(result, &_sha256Context);
}

@end
