//
//  BMYouTube.h
//  BMCommons
//
//  Created by Werner Altewischer on 24/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMGoogle/BMGoogle.h>
#import <BMMedia/BMMedia.h>
#import <BMYouTube/BMStyleSheet+BMYouTube.h>

#define BMYouTubeLocalizedString(key, comment) NSLocalizedStringFromTableInBundle(key, @"BMYouTube", [BMYouTube bundle], comment)

/**
 BMYouTube module
 */
@interface BMYouTube : NSObject
{
    
}

+ (NSBundle *)bundle;
+ (id)instance;

@end