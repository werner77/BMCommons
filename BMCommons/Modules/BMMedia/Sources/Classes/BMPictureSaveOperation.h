//
//  BMPictureSaveOperation.h
//  BMCommons
//
//  Created by Werner Altewischer on 21/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaSaveOperation.h>

/**
 @enum Sizes for saving a picture
 
 @see [BMPictureSaveOperation sizesToSave]
 */
typedef NS_ENUM(NSUInteger, BMPictureSize) {
    BMPictureSizeThumbnail = 0x1,
    BMPictureSizeMedium = 0x2,
    BMPictureSizeFull = 0x4,
    BMPictureSizeAll = 0xFF
};

/**
 Operation to save a picture in multiple sizes.
 
 Uses [BMPictureContainer saveFullSizeImage], [BMMediaContainer saveThumbnailImage] and [BMMediaContainer saveMidSizeImage].
 Optionally also saves the image to the camera roll.
 */
@interface BMPictureSaveOperation : BMMediaSaveOperation

/**
 The image to save to the picture.
 */
@property (readonly) UIImage *image;

/**
 Optional thumbnail image.
 
 If not provided the image set will be resized.
 */
@property (strong) UIImage *thumbnailImage;

/**
 Whether or not to also save to the iOS camera roll.
 */
@property (assign) BOOL saveToCameraRoll;

/**
 Sizes to save specified by the enum BMPictureSize which can be logically OR-ed to save multiple sizes.
 
 Defaults to BMPictureSizeAll.
 */
@property (assign) NSUInteger sizesToSave;

/**
 Initializes with image to save and picture to save to.
 */
- (id)initWithImage:(UIImage *)theImage picture:(NSObject <BMPictureContainer>*)thePicture;

/**
 This picture set by the initializer.
 */
- (id <BMPictureContainer>)picture;

@end
