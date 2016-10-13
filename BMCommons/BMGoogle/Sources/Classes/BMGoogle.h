//
//  BMGoogle.h
//  BMCommons
//
//  Created by Werner Altewischer on 24/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#if BM_PRIVATE_ENABLED
#import <BMGoogle/BMGoogle_Private.h>
#endif

#ifndef BMGoogleCheckLicense
#define BMGoogleCheckLicense() {}
#endif


#import <BMCore/BMCore.h>
#import <BMUICore/BMUICore.h>
#import <GData/GData.h>

/**
 BMGoogle module
 */
@interface BMGoogle : NSObject<BMLicensedModule>
{
    
}

+ (id)instance;
+ (NSBundle *)bundle;

@end