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

UIInterfaceOrientation BMInfaceOrientationFromAssetOrientation(ALAssetOrientation assetOrientation) {
    UIInterfaceOrientation interfaceOrientation = UIInterfaceOrientationUnknown;
    switch (assetOrientation) {
        case ALAssetOrientationUpMirrored:
        case ALAssetOrientationUp:
            interfaceOrientation = UIInterfaceOrientationPortrait;
            break;
        case ALAssetOrientationDown:
        case ALAssetOrientationDownMirrored:
            interfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        case ALAssetOrientationLeft:
        case ALAssetOrientationLeftMirrored:
            interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
            break;
        case ALAssetOrientationRight:
        case ALAssetOrientationRightMirrored:
            interfaceOrientation = UIInterfaceOrientationLandscapeRight;
            break;
    }
    return interfaceOrientation;
};

UIImageOrientation BMImageOrientationFromAssetOrientation(ALAssetOrientation assetOrientation) {
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    switch (assetOrientation) {
        case ALAssetOrientationUpMirrored:
            imageOrientation = UIImageOrientationUpMirrored;
            break;
        case ALAssetOrientationUp:
            imageOrientation = UIImageOrientationUp;
            break;
        case ALAssetOrientationDown:
            imageOrientation = UIImageOrientationDown;
            break;
        case ALAssetOrientationDownMirrored:
            imageOrientation = UIImageOrientationDownMirrored;
            break;
        case ALAssetOrientationLeft:
            imageOrientation = UIImageOrientationLeft;
            break;
        case ALAssetOrientationLeftMirrored:
            imageOrientation = UIImageOrientationLeftMirrored;
            break;
        case ALAssetOrientationRight:
            imageOrientation = UIImageOrientationRight;
            break;
        case ALAssetOrientationRightMirrored:
            imageOrientation = UIImageOrientationRightMirrored;
            break;
    }
    return imageOrientation;
};

@end
