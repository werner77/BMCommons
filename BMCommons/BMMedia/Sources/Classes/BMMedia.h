//
//  BMMedia.h
//  BMCommons
//
//  Created by Werner Altewischer on 21/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#if BM_PRIVATE_ENABLED
#import <BMMedia/BMMedia_Private.h>
#endif

#ifndef BMMediaCheckLicense
#define BMMediaCheckLicense() {}
#endif


#import <BMCore/BMCore.h>
#import <BMUICore/BMUICore.h>
#import <BMMedia/BMMediaContainer.h>
#import <BMMedia/BMStyleSheet+BMMedia.h>

#define BMMediaLocalizedString(key, comment) NSLocalizedStringFromTableInBundle(key, @"BMMedia", [BMMedia bundle], comment)

/**
 BMMedia module
 */
@interface BMMedia : NSObject<BMLicensedModule>


+ (id)instance;
+ (NSBundle *)bundle;
+ (BMMediaOrientation)mediaOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end