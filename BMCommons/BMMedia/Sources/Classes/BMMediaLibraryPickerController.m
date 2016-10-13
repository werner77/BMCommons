//
//  MediaLibraryPickerController.m
//  BTFD
//
//  Created by Werner Altewischer on 14/07/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMMediaLibraryPickerController.h"
#import "BMAlbumPickerController.h"
#import "ALAsset+BMMedia.h"
#import <BMCore/BMFileHelper.h>
#import <BMCore/BMApplicationHelper.h>
#import <BMUICore/BMImageHelper.h>
#import <BMUICore/BMDialogHelper.h>
#import <BMUICore/BMBusyView.h>
#import <CoreGraphics/CoreGraphics.h>
#import "BMAssetPickerController.h"
#import <BMMedia/BMAssetPickerController.h>
#import <BMMedia/BMMedia.h>

@interface BMMediaLibraryPickerController() <BMAssetPickerControllerDelegate>

@end

@interface BMMediaLibraryPickerController(Private)

- (void)copyAssets:(NSArray *)assets;

@end

@implementation BMMediaLibraryPickerController {
	BMAssetPickerController *imagePickerController;
}

@synthesize copyRawPictures;

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)dealloc {
	imagePickerController.delegate = nil;
	BM_RELEASE_SAFELY(imagePickerController);
}

- (BOOL)presentFromViewController:(UIViewController *)vc withTransitionStyle:(UIModalTransitionStyle)transitionStyle {
	if (!imagePickerController) {
		[super presentFromViewController:vc withTransitionStyle:transitionStyle];
		
		imagePickerController = [[BMAssetPickerController alloc] init];
		imagePickerController.delegate = self;
        imagePickerController.modalTransitionStyle = transitionStyle;
        
        [imagePickerController setMaxNumberOfSelectableAssets:self.maxSelectablePictures ofKind:BMMediaKindPicture];
        [imagePickerController setMaxNumberOfSelectableAssets:self.maxSelectableVideos ofKind:BMMediaKindVideo];
        [imagePickerController setMaxNumberOfSelectableAssets:self.maxSelectableMedia ofKind:BMMediaKindUnknown];
        imagePickerController.allowMixedMediaTypes = self.allowMixedMediaTypes;
        
        if ([self.delegate respondsToSelector:@selector(mediaPickerController:willPresentViewController:)]) {
            [self.delegate mediaPickerController:self willPresentViewController:imagePickerController];
        }
        
        [vc presentViewController:imagePickerController animated:YES completion:nil];
        return YES;
	}
    return NO;
}

- (void)dismissWithCancel:(BOOL)cancel {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
	imagePickerController.delegate = nil;
	BM_RELEASE_SAFELY(imagePickerController);
	[super dismissWithCancel:cancel];
}

- (UIViewController *)rootViewController {
    return imagePickerController;
}

#pragma mark -
#pragma mark BMAssetPickerControllerDelegate implementation

- (void)assetPickerController:(BMAssetPickerController *)picker didFinishPickingMediaWithAssets:(NSArray *)assets {
    
    //check duration
    BOOL valid = YES;
    if (self.maxDuration > 0.0) {
        for (ALAsset *asset in assets) {
            if (asset.bmMediaKind == BMMediaKindVideo) {
                NSNumber *duration = [asset valueForProperty:ALAssetPropertyDuration];
                if ([duration doubleValue] > (self.maxDuration + 1.0)) {
                    valid = NO;
                }
            }
        }
    }
	
    if (valid) {
        
        if (assets.count > 0) {
            [BMBusyView showBusyViewWithMessage:BMMediaLocalizedString(@"medialibrarypicker.busyview.copying", @"Copying media...") andProgress:0];
            [BMApplicationHelper doEvents];
            
            [self copyAssets:assets];
            
            [BMBusyView hideBusyView];
            [BMApplicationHelper doEvents];
        }
        [self dismiss];
    } else {
        [self maxDurationReached];
    }
}

- (void)assetPickerControllerDidCancel:(BMAssetPickerController *)picker {
	[self cancel];
}

- (void)assetPickerControllerReachedMaxSelectableAssets:(BMAssetPickerController *)picker {
    [self maxSelectableMediaReached];
}

- (BOOL)assetPickerController:(BMAssetPickerController *)picker shouldAllowSelectionOfAsset:(ALAsset *)asset {
    
    if (![self.delegate respondsToSelector:@selector(mediaPickerController:shouldAllowSelectionOfMedia:)]) {
        return YES;
    }
    
    ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
    id <BMMediaContainer> theMedia = nil;
    if (asset.bmMediaKind == BMMediaKindPicture) {
        theMedia = [self.delegate pictureContainerForMediaPickerController:self];
    } else if (asset.bmMediaKind == BMMediaKindVideo) {
        theMedia = [self.delegate videoContainerForMediaPickerController:self];
    }
    theMedia.entryUrl = [[assetRepresentation url] absoluteString];
    theMedia.entryId = theMedia.entryUrl;
    return [self.delegate mediaPickerController:self shouldAllowSelectionOfMedia:theMedia];
}

@end

@implementation BMMediaLibraryPickerController(Private)

- (NSString *)extensionFromAssetRepresentation:(ALAssetRepresentation *)assetRepresentation withDefault:(NSString *)defaultExt {
    //Extract the extension from the asset URL
    //e.g.: assets-library://asset/asset.MOV?id=1000000132&ext=MOV
    NSString *assetUrl = [[[assetRepresentation url] absoluteString] lowercaseString];
    
    NSRange range = [assetUrl rangeOfString:@"ext="];
    
    NSString *ext= defaultExt;
    
    if (range.location != NSNotFound) {
        NSUInteger pos = range.location + range.length;
        NSUInteger startPos = pos;
        while (pos < assetUrl.length) {
            unichar c = [assetUrl characterAtIndex:pos];
            if (c == '&') {
                break;
            }
            pos++;
        }
        ext = [assetUrl substringWithRange:NSMakeRange(startPos, pos - startPos)];
    }

    return ext;
}

- (NSError *)copyAsset:(ALAssetRepresentation *)assetRepresentation toStream:(NSOutputStream *)fos withProgressBlock:(void (^)(NSUInteger doneCount, NSUInteger totalCount))block {
    
    
    NSUInteger totalLength = [assetRepresentation size];
    NSUInteger length = totalLength;
    NSUInteger bufferSize = 1024 * 1024;
    NSUInteger offset = 0;
    
    uint8_t *buffer = malloc(sizeof(uint8_t) * bufferSize);
    NSError *error = nil;
    
    [fos open];
        
    while (length > 0) {
        NSUInteger bytesRead = [assetRepresentation getBytes:buffer fromOffset:offset length:bufferSize error:&error];
        
        if (bytesRead == 0) {
            break;
        } else {
            [fos write:buffer maxLength:bytesRead];
        }
        
        offset += bytesRead;
        if (length > bytesRead) {
            length -= bytesRead;
        } else {
            length = 0;
        }
        
        if (block != nil) block(offset, totalLength);
        
        [BMApplicationHelper doEvents];
    }
    [fos close];
    free(buffer);
    return error;
}

- (NSString *)tempFileWithCopiedAsset:(ALAssetRepresentation *)assetRepresentation withProgress:(CGFloat)progress andCount:(NSUInteger)count defaultExtension:(NSString *)defaultExtension {
    NSString *ext = [self extensionFromAssetRepresentation:assetRepresentation withDefault:defaultExtension];
    NSString *tempFilePath = [BMFileHelper uniqueTempFileWithExtension:ext];
    NSOutputStream *fos = [[NSOutputStream alloc] initToFileAtPath:tempFilePath append:NO];
    
    __block CGFloat incrementalProgress = 0.0;
    
    NSError *error = [self copyAsset:assetRepresentation toStream:fos withProgressBlock:^(NSUInteger offset, NSUInteger totalLength) {
        incrementalProgress = offset/((CGFloat)(totalLength * count));
        [BMBusyView showBusyViewWithMessage:BMMediaLocalizedString(@"medialibrarypicker.busyview.copying", @"Copying media...") andProgress:(progress + incrementalProgress)];
    }];
    
    if (error) {
        //Error occured
        LogWarn(@"Could not read bytes from asset: %@: %@", assetRepresentation, error);
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:tempFilePath error:nil];
        return nil;
    } else {
        return tempFilePath;
    }
}

- (void)copyAssets:(NSArray *)assets {
	CGFloat progress = 0.0;
	NSUInteger count = assets.count;
	NSUInteger counter = 0;
	for (ALAsset *asset in assets) {
		@autoreleasepool {
			ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
			
			id <BMMediaContainer> theMedia = nil;
			
			if (asset.bmMediaKind == BMMediaKindPicture) {

            //Following code enables saving of full size image

            theMedia = [self.delegate pictureContainerForMediaPickerController:self];
            
            if (self.copyRawPictures) {
                
                NSString *tempFilePath = [self tempFileWithCopiedAsset:assetRepresentation
                                                      withProgress:progress
                                                          andCount:count
                                                  defaultExtension:@"jpg"];
                
                if (tempFilePath) {
                    id <BMPictureContainer> pic = [self.delegate pictureContainerForMediaPickerController:self];
                    [pic setDataFromFile:tempFilePath];
                    theMedia = pic;
                }
                
            } else {
                UIImageOrientation assetOrientation = (UIImageOrientation) [[asset valueForProperty:ALAssetPropertyOrientation] intValue];
                UIImage *fullResImage = [[UIImage alloc] initWithCGImage:[assetRepresentation fullResolutionImage] scale:1.0 orientation:assetOrientation];
                
                if (!fullResImage){
                    LogWarn(@"Could not read bytes from picture asset: %@", asset);
                } else {
                    id <BMPictureContainer> pic = [self.delegate pictureContainerForMediaPickerController:self];
                    [pic saveFullSizeImage:fullResImage];                    
                    theMedia = pic;
                }
            }
            
			} else if (asset.bmMediaKind == BMMediaKindVideo) {
            
            NSNumber *duration = [asset valueForProperty:ALAssetPropertyDuration];
            
            NSString *tempFilePath = [self tempFileWithCopiedAsset:assetRepresentation
                                                  withProgress:progress
                                                      andCount:count
                                              defaultExtension:@"mov"];
            
				if (tempFilePath) {
					id <BMVideoContainer> video = [self.delegate videoContainerForMediaPickerController:self];
					[video setDataFromFile:tempFilePath];
                video.duration = duration;
					theMedia = video;
				}            
			}
			
			if (theMedia) {
            
            theMedia.entryUrl = [[assetRepresentation url] absoluteString];
            theMedia.entryId = theMedia.entryUrl;
							
            UIInterfaceOrientation interfaceOrientation = (UIImageOrientation)[assetRepresentation orientation];
            
            UIImage *fullscreenImage = nil;
            if (BMOSVersionIsAtLeast(@"5.0")) {
                fullscreenImage = [[UIImage alloc] initWithCGImage:[assetRepresentation fullScreenImage]];
            } else {
                UIImage *tempImage = [[UIImage alloc] initWithCGImage:[assetRepresentation fullScreenImage] scale:[assetRepresentation scale] orientation:interfaceOrientation];
                fullscreenImage = [BMImageHelper rotateImage:tempImage];
            }
				
            if ([theMedia conformsToProtocol:@protocol(BMMediaWithSizeContainer)]) {
                BMMediaOrientation mediaOrientation = [BMMedia mediaOrientationFromInterfaceOrientation:interfaceOrientation];
                ((id <BMMediaWithSizeContainer>)theMedia).mediaOrientation = mediaOrientation;
            }
				
            [theMedia setMidSizeImage:fullscreenImage];
				
				UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:[asset thumbnail]];
				
				[theMedia setThumbnailImage:thumbnailImage];
				
				
            [self addMedia:theMedia];
			}
			counter++;
			progress = counter/((CGFloat)count);
			[BMBusyView showBusyViewWithMessage:BMMediaLocalizedString(@"medialibrarypicker.busyview.copying", @"Copying media...") andProgress:progress];
			[BMApplicationHelper doEvents];
		}
	}
	
}

@end


