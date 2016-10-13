//
//  BMLicenseKey_Private.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/25/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#ifndef BMCommons_BMLicenseKey_Private_h
#define BMCommons_BMLicenseKey_Private_h

#import  <BMCore/BMCore.h>

#if VERIOUS_LICENSING_ENABLED
#import "LicenseMgr.h"
#endif

#define NUMBER_OF_COORDINATES 4

#define ENCRYPTION_KEY @"adfjbsdknj122r7r9djxfbvqqwliweif"

#define LICENSE_KEY_FUNCTION(x) ({ \
int32_t ret = 0; \
if (x != 0) { \
if (x < -INT32_MAX) { \
x = -INT32_MAX; \
} \
double correctedX = (M_PI * (double)x) / ((double)INT32_MAX); \
double doubleY = sin(correctedX - M_PI) / (correctedX - M_PI); \
ret = BMShortenIntSafely(lround(INT32_MAX * doubleY), nil); \
} \
ret; \
})

#undef BM_LICENSED_MODULE_IMPLEMENTATION

#if TARGET_IPHONE_SIMULATOR || (!BM_LICENSING_ENABLED && !VERIOUS_LICENSING_ENABLED)

#define BM_LICENSED_MODULE_IMPLEMENTATION(name) \
BOOL is##name##LicenseValid(void) { \
return YES; \
} \
- (void)registerLicenseKey:(NSString *)licenseKey {}

#elif BM_LICENSING_ENABLED

#define BM_LICENSED_MODULE_IMPLEMENTATION(name) \
static BOOL _licenseValid = NO; \
BOOL is##name##LicenseValid(void) { \
return _licenseValid; \
} \
- (void)registerLicenseKey:(NSString *)licenseKey { \
_licenseValid = YES; \
_licenseValid = BMCheckLicenseKeyForModule(self, licenseKey, &_licenseValid); \
}

#elif VERIOUS_LICENSING_ENABLED

#define BM_LICENSED_MODULE_IMPLEMENTATION(name) \
static BOOL _licenseValid = NO; \
BOOL is##name##LicenseValid(void) { \
return _licenseValid; \
} \
- (void)initWithLicense:(NSData *)signedHash validity:(NSString *)validity { \
    _licenseValid = BMValidateVeriousLicense(signedHash, validity); \
} \
- (void)registerLicenseKey:(NSString *)licenseKey {}

#endif

#endif


