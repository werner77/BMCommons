//
//  MediaLibraryPickerController.h
//  BTFD
//
//  Created by Werner Altewischer on 14/07/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaPickerController.h>

/**
 Media picker controller to select multiple items from the user's media library.
 
 The ALAsset API is used directly for this. Depending on the type of asset the delegate is asked to create an instance of
 BMPictureContainer or BMVideoContainer for each selected asset.
 */
@interface BMMediaLibraryPickerController : BMMediaPickerController 

/**
 If set to YES the raw picture data is copied as fullsizeImage.
 
 If set to NO the image is rescaled according to the max resolution as specified by [BMPictureContainer maxFullSizeResolution].
 The [BMPictureContainer saveFullSizeImage:] method is used to save the image then.
 */
@property (nonatomic, assign) BOOL copyRawPictures;

@end
