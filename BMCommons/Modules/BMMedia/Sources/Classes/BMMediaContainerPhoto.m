//
//  BMMediaContainerPhoto.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMMediaContainerPhoto.h>
#import <BMCommons/BMMediaContainerPhotoSource.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMImageHelper.h>
#import <BMMedia/BMMedia.h>
#import <BMCommons/UIScreen+BMCommons.h>

@interface BMMediaContainerPhoto(Private)

- (CGSize)getSizeFromMedia;
- (void)setMedias:(NSArray *)theMedias;

@end


@implementation BMMediaContainerPhoto {
	NSUInteger activeIndex;
	__weak id<BMTTPhotoSource> photoSource;
	NSInteger index;
	CGSize size;
    BMMediaOrientation cachedOrientation;
    NSMutableArray *medias;
    BOOL orientationDetermined;
}

@synthesize photoSource;
@synthesize medias;

- (id)initWithMedia:(id <BMMediaContainer>)theMedia {
	NSArray *theArray = theMedia ? @[theMedia] : nil;
    return [self initWithMedias:theArray];
}

- (id)init {
    if ((self = [super init])) {

    }
    return self;
}

- (id)initWithMedias:(NSArray *)theMedias {
    if ((self = [self init])) {
		self.photoSource = nil;
        self.medias = theMedias;
	}
	return self;
}


- (NSInteger)index {
    NSInteger theIndex = -1;
    if (self.photoSource) {
        theIndex = [self.photoSource indexOfPhoto:self];
    }
    return theIndex;
}

- (BOOL)isVideo {
    return self.media.mediaKind == BMMediaKindVideo;
}

- (BMMediaOrientation)orientation {
    BMMediaOrientation theOrientation = cachedOrientation;
    
    if (!orientationDetermined) {
        if (theOrientation == BMMediaOrientationUnknown) {
            [self.media conformsToProtocol:@protocol(BMMediaWithSizeContainer)] ?
            [(id <BMMediaWithSizeContainer>)self.media mediaOrientation] :
            BMMediaOrientationUnknown;
        }
        if (theOrientation == BMMediaOrientationUnknown) {
            if (size.width > size.height) {
                theOrientation = BMMediaOrientationLandscape;
            } else if (size.height > size.width) {
                theOrientation = BMMediaOrientationPortrait;
            }
        }
        
        if (theOrientation == BMMediaOrientationUnknown) {
            //Still unknown: try to guess from thumbnail
            UIImage *image = self.media.midSizeImage;
            
            if (!image && [self.media conformsToProtocol:@protocol(BMPictureContainer)]) {
                image = ((id <BMPictureContainer>)self.media).image;
            }
            
            if (image) {
                if (image.size.width > image.size.height) {
                    theOrientation = BMMediaOrientationLandscape;
                } else if (image.size.width < image.size.height) {
                    theOrientation = BMMediaOrientationPortrait;
                }
            } else {
                image = self.media.thumbnailImage;
                if (image) {
                    UIInterfaceOrientation interfaceOrientation = [BMImageHelper guessOrientationFromImage:image];
                    theOrientation = [BMMedia mediaOrientationFromInterfaceOrientation:interfaceOrientation];
                }
            }
        }
        cachedOrientation = theOrientation;
        orientationDetermined = YES;
    }
    
    return theOrientation;
}

- (CGSize)size {
    BMMediaOrientation theOrientation = self.orientation;
    
    CGFloat width, height;
    height = [UIScreen mainScreen].bmPortraitBounds.size.height;
    width = [UIScreen mainScreen].bmPortraitBounds.size.width;
    
    if (theOrientation == BMMediaOrientationLandscape) {
		return CGSizeMake(height, width);
	} else if (theOrientation == BMMediaOrientationPortrait) {
		return CGSizeMake(width, height);
	} else {
		return size;
	}
}

- (void)setSize:(CGSize)theSize {
	size = theSize;
}

- (void)setCaption:(NSString *)caption {
	self.media.caption = caption;
}

- (NSString *)caption {
    if ([self.photoSource isKindOfClass:[BMMediaContainerPhotoSource class]]) {
        BMMediaContainerPhotoSource *ps = (BMMediaContainerPhotoSource *)self.photoSource;
        return [ps captionForMedia:self.media];
    } else {
        return self.media.caption;
    }
}

/**
 * Gets the URL of one of the differently sized versions of the photo.
 */
- (NSString*)URLForVersion:(BMTTPhotoVersion)version {
	NSString *url = nil;
	if (version == BMTTPhotoVersionLarge || version == BMTTPhotoVersionMedium) {
		url = self.media.midSizeImageUrl;
		if (!url && self.media.mediaKind == BMMediaKindPicture) {
			url = self.media.url;
		}
	} else {
		url = self.media.thumbnailImageUrl;
	}
	return url;
}

- (id <BMMediaContainer>)media {
    if (activeIndex < medias.count) {
        return medias[activeIndex];
    } else {
        return nil;
    }
}

- (void)removeMedia:(id<BMMediaContainer>)theMedia {
    [medias removeObject:theMedia];
    if (activeIndex >= medias.count) {
        if (medias.count > 0) {
            activeIndex  = medias.count - 1;
        } else {
            activeIndex = NSNotFound;
        }
    }
}

- (void)setActiveMedia:(id <BMMediaContainer>)theMedia {
    [self setActiveMediaIndex:[medias indexOfObject:theMedia]];
}

- (void)setActiveMediaIndex:(NSUInteger)i {
    if (i < medias.count) {
        activeIndex = i;
    } else if (medias.count > 0)  {
        activeIndex = 0;
    } else {
        activeIndex = NSNotFound;
    }
}

@end

@implementation BMMediaContainerPhoto(Private)

- (CGSize)getSizeFromMedia {
	UIImage *thumbnail = self.media.thumbnailImage;
	CGSize ret = CGSizeZero;
	if (thumbnail != nil) {
		ret = thumbnail.size;
	} 
	return ret;
}

- (void)setMedias:(NSArray *)theMedias {
    activeIndex = NSNotFound;
    if (medias != theMedias) {
        cachedOrientation = BMMediaOrientationUnknown;
        orientationDetermined = NO;
        size = CGSizeZero;
        medias = nil;
        if (theMedias) {
            medias = [[NSMutableArray alloc] initWithArray:theMedias];
            if (theMedias.count > 0) {
                activeIndex = 0;
            }
        }
    }
}


@end
