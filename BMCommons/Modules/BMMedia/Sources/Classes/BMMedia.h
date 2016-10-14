//
//  BMMedia.h
//  BMCommons
//
//  Created by Werner Altewischer on 21/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCore.h>
#import <BMCommons/BMUICore.h>
#import <BMMedia/BMMediaContainer.h>
#import <BMMedia/BMStyleSheet+BMMedia.h>

#define BMMediaLocalizedString(key, comment) NSLocalizedStringFromTableInBundle(key, @"BMMedia", [BMMedia bundle], comment)

/**
 BMMedia module
 */
@interface BMMedia : NSObject


+ (id)instance;
+ (NSBundle *)bundle;
+ (BMMediaOrientation)mediaOrientationFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
