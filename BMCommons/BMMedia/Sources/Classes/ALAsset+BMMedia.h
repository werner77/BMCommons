//
//  ALAsset+BMMedia.h
//  BMCommons
//
//  Created by Werner Altewischer on 16/07/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <BMMedia/BMMediaContainer.h>

/**
 Category on ALAsset for the BMMedia module.
 */
@interface ALAsset(BMMedia) 

/**
 The BMMediaKind of the asset.
 */
- (BMMediaKind)bmMediaKind;

@end
