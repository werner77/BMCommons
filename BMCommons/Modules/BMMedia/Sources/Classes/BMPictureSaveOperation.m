//
//  BMPictureSaveOperation.m
//  BMCommons
//
//  Created by Werner Altewischer on 21/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMPictureSaveOperation.h>
#import <BMMedia/BMMedia.h>

@implementation BMPictureSaveOperation {
	UIImage *image;
	BOOL saveToCameraRoll;
}

@synthesize image, thumbnailImage, saveToCameraRoll, sizesToSave;

- (id)initWithImage:(UIImage *)theImage picture:(id <BMPictureContainer>)thePicture {
	if ((self = [super initWithMedia:thePicture])) {
		image = theImage;
        sizesToSave = BMPictureSizeAll;
	}
	return self;
}

- (void)dealloc {
    BM_RELEASE_SAFELY(thumbnailImage);
	BM_RELEASE_SAFELY(image);
}

- (id <BMPictureContainer>)picture {
	return (id <BMPictureContainer>)self.media;
}

- (void)performOperation {
	if (![self isCancelled] && (self.sizesToSave & BMPictureSizeThumbnail)) {
        if (self.thumbnailImage) {
            [self.picture setThumbnailImage:self.thumbnailImage];
        } else {
            [self.picture saveThumbnailImage:self.image];
        }
	}

    if (![self isCancelled] && (self.sizesToSave & BMPictureSizeMedium)) {
        [self.picture saveMidSizeImage:self.image];
    }
    
    if (![self isCancelled] && (self.sizesToSave & BMPictureSizeFull)) {
		[self.picture saveFullSizeImage:self.image];
	}
	
	if (self.saveToCameraRoll && ![self isCancelled]) {
		UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
	}
}

@end
