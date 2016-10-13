//
//  BMYouTube.h
//  BMCommons
//
//  Created by Werner Altewischer on 24/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#if BM_PRIVATE_ENABLED
#import <BMYouTube/BMYouTube_Private.h>
#endif

#ifndef BMYouTubeCheckLicense
#define BMYouTubeCheckLicense() {}
#endif


#import <BMGoogle/BMGoogle.h>
#import <BMMedia/BMMedia.h>
#import <BMYouTube/BMStyleSheet+BMYouTube.h>

#define BMYouTubeLocalizedString(key, comment) NSLocalizedStringFromTableInBundle(key, @"BMYouTube", [BMYouTube bundle], comment)

/**
 BMYouTube module
 */
@interface BMYouTube : NSObject<BMLicensedModule>
{
    
}

+ (NSBundle *)bundle;
+ (id)instance;

@end