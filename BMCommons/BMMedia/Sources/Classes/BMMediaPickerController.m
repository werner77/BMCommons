//
//  BMMediaPickerController.m
//  BMCommons
//
//  Created by Werner Altewischer on 14/07/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMMediaPickerController.h"
#import <BMUICore/BMDialogHelper.h>
#import <BMMedia/BMMedia.h>
#import <BMCore/BMCore.h>

@implementation BMMediaPickerController {
	NSMutableArray *media;
	id <BMMediaPickerControllerDelegate> __weak delegate;
    UIViewController *__weak parentViewController;
    NSUInteger maxSelectablePictures;
    NSUInteger maxSelectableVideos;
    NSUInteger maxSelectableMedia;
    BOOL allowMixedMediaTypes;
    NSTimeInterval maxDuration;
}

@synthesize delegate, parentViewController;

@synthesize maxSelectableMedia, maxSelectablePictures, maxSelectableVideos, allowMixedMediaTypes;
@synthesize maxDuration, styleSheet;

- (id)init {
	if ((self = [super init])) {
        BMMediaCheckLicense();
		media = [NSMutableArray new];
        maxDuration = 0.0;
	}
	return self;
}

- (void)dealloc {
    for (id <BMMediaContainer> m in media) {
		[m removeDelegate:self];
	}
    BM_RELEASE_SAFELY(media);
    BM_RELEASE_SAFELY(styleSheet);
}

- (BOOL)presentFromViewController:(UIViewController *)vc withTransitionStyle:(UIModalTransitionStyle)transitionStyle {
    //Start fresh
    parentViewController = vc;
    if (self.styleSheet) {
        [BMStyleSheet pushStyleSheet:self.styleSheet];
    }
    return NO;
}

- (BOOL)presentFromViewController:(UIViewController *)vc {
    return [self presentFromViewController:vc withTransitionStyle:UIModalTransitionStyleCoverVertical];
}

- (void)cancel {
    [self dismissWithCancel:YES];
}

- (void)dismiss {
    [self dismissWithCancel:NO];
}

- (NSUInteger)mediaCount {
    return media.count;
}

- (NSArray *)media {
    return [NSArray arrayWithArray:media];
}

- (void)addMedia:(id <BMMediaContainer>)m {
    [m addDelegate:self];
    [media addObject:m];
}

- (void)removeMedia:(id <BMMediaContainer>)m {
    [m removeDelegate:self];
    [media removeObjectIdenticalTo:m];
}

- (NSUInteger)pictureCount {
    NSUInteger i = 0;
    for (id <BMMediaContainer> m in media) {
        if (m.mediaKind == BMMediaKindPicture) {
            i++;
        }
    }
    return i;
}

- (NSUInteger)videoCount {
    NSUInteger i = 0;
    for (id <BMMediaContainer> m in media) {
        if (m.mediaKind == BMMediaKindVideo) {
            i++;
        }
    }
    return i;
}

- (UIViewController *)rootViewController {
    return nil;
}

#pragma mark -
#pragma mark MediaContainerDelegate implementation

- (void)mediaContainerDidUpdate:(id <BMMediaContainer>)mediaContainer {
    
}

- (void)mediaContainerWasDeleted:(id <BMMediaContainer>)mediaContainer {
	[self removeMedia:mediaContainer];
}

@end

@implementation BMMediaPickerController(Protected)

- (BOOL)checkSelectionLimitsForNewMediaOfKind:(BMMediaKind)kind {
    NSUInteger pictureCount = [self pictureCount];
    NSUInteger videoCount = [self videoCount];
    NSUInteger mediaCount = [self mediaCount];
    
    if ((pictureCount >= self.maxSelectablePictures && kind == BMMediaKindPicture) ||
        (videoCount >= self.maxSelectableVideos && kind == BMMediaKindVideo) ||
        (mediaCount >= self.maxSelectableMedia) ||
        (!self.allowMixedMediaTypes && pictureCount > 0 && kind == BMMediaKindVideo) ||
        (!self.allowMixedMediaTypes && videoCount > 0 && kind == BMMediaKindPicture)) {
        [self maxSelectableMediaReached];
        return NO;
    } else {
        BOOL ret = YES;
        if ([self.delegate respondsToSelector:@selector(mediaPickerController:shouldAllowSelectionOfMedia:)]) {
            id <BMMediaContainer> theMedia = (kind == BMMediaKindVideo) ? (id <BMMediaContainer>)[self.delegate videoContainerForMediaPickerController:self] : (id <BMMediaContainer>)[self.delegate pictureContainerForMediaPickerController:self];
            ret = [self.delegate mediaPickerController:self shouldAllowSelectionOfMedia:theMedia];
        }
        return ret;
    }
}

- (void)maxSelectableMediaReached {
    if ([self.delegate respondsToSelector:@selector(mediaPickerControllerReachedMaxSelectableMedia:)]) {
        [self.delegate mediaPickerControllerReachedMaxSelectableMedia:self];
    }
}

- (void)maxDurationReached {
    if ([self.delegate respondsToSelector:@selector(mediaPickerControllerReachedMaxDuration:)]) {
        [self.delegate mediaPickerControllerReachedMaxDuration:self];
    }
}

- (void)dismissWithCancel:(BOOL)cancel {
    parentViewController = nil;
    [BMStyleSheet popStyleSheet];
    if (cancel) {
        [self.delegate mediaPickerControllerWasCancelled:self];
    } else {
        NSArray *theMedia = [NSArray arrayWithArray:media];
        [self.delegate mediaPickerControllerWasDismissed:self withMedia:theMedia];
    }
}

@end
