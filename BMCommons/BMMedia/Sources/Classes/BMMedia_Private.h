//
//  BMMedia_Private.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/25/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMLicenseKeyHelper_Private.h>
#import <BMCore/BMLicenseKey_Private.h>

#if BM_LICENSING_ENABLED || VERIOUS_LICENSING_ENABLED
#undef BMMediaCheckLicense
#define BMMediaCheckLicense() if (!isBMMediaLicenseValid()) { BMThrowLicenseException([BMMedia instance]); }
#endif

BOOL isBMMediaLicenseValid(void);
