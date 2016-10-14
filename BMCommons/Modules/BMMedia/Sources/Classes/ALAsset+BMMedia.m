//
//  ALAsset+BMMedia.m
//  BMCommons
//
//  Created by Werner Altewischer on 16/07/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "ALAsset+BMMedia.h"


@implementation ALAsset(Media)

- (BMMediaKind)bmMediaKind {
    NSString *typeString = [self valueForProperty:ALAssetPropertyType];
    BMMediaKind mediaKind = BMMediaKindUnknown;
    if ([typeString isEqual:ALAssetTypePhoto]) {
        mediaKind = BMMediaKindPicture;
    } else if ([typeString isEqual:ALAssetTypeVideo]) {
        mediaKind = BMMediaKindVideo;
    }
	return mediaKind;
}

@end
