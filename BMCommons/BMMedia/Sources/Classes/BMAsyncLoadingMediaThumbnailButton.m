//
//  BMAsyncLoadingMediaThumbnailButton.m
//  BMCommons
//
//  Created by Werner Altewischer on 17/04/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAsyncLoadingMediaThumbnailButton.h>
#import <BMCore/BMStringHelper.h>
#import <BMCore/BMURLCache.h>
#import <BMMedia/BMMediaContainer.h>
#import <BMCore/BMAsyncDataLoader.h>
#import <BMUICore/UIImage+BMCommons.h>
#import <BMMedia/BMMedia.h>

@interface BMTimerInfo : NSObject {
    id __weak target;
    id userInfo;
}

@property (nonatomic, weak) id target;
@property (nonatomic, strong) id userInfo;

@end

@implementation BMTimerInfo

@synthesize target, userInfo;

- (void)dealloc {
    BM_RELEASE_SAFELY(userInfo);
}

@end

@interface BMAsyncLoadingMediaThumbnailButton()<BMAsyncDataLoaderDelegate>
@end

@interface BMAsyncLoadingMediaThumbnailButton(Private)

+ (void)timerFired:(NSTimer *)theTimer;
- (void)setNextMedia:(NSArray *)allMedia;
- (BMMediaThumbnailView *)thumbnailView;
- (void)setImage:(UIImage *)theImage animated:(BOOL)animated;

- (BOOL)popAnimated;
- (void)pushAnimated:(BOOL)animated;
- (void)cancelDataLoaders;
- (void)setup;
- (void)loadFullSizeImageForMedia:(id <BMMediaContainer>)mediaContainer;

@end

@implementation BMAsyncLoadingMediaThumbnailButton {
    id <BMMediaContainer> media;
    BMEmbeddedVideoView *embeddedVideoView;
    BOOL useEmbeddedVideoView;
    BOOL useFullSizeImages;
    NSTimer *timer;
    NSMutableArray *animatedArray;
    NSMutableArray *dataLoaders;
    BOOL ignorePlaceHolderForNilMedia;
    id <BMAsyncLoadingMediaThumbnailButtonDelegate> __weak delegate;
    BOOL overlayDisabled;
}

@synthesize media, useEmbeddedVideoView, useFullScreenImages, ignorePlaceHolderForNilMedia, delegate, overlayDisabled, embeddedVideoView;

- (id)initWithFrame:(CGRect)theFrame {
    if ((self = [super initWithFrame:theFrame])) {
        BMMediaCheckLicense();
        BMMediaThumbnailView *thumbnailView = [[BMMediaThumbnailView alloc] initWithFrame:self.bounds];
        thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:thumbnailView];
        self.imageView = thumbnailView;
        [self setup];
        [self setShowActivity:YES];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        BMMediaCheckLicense();
        [self setup];
        [self setShowActivity:YES];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)dealloc {
    [timer invalidate];
    timer = nil;
    [self cancelDataLoaders];
    BM_RELEASE_SAFELY(dataLoaders);
    BM_RELEASE_SAFELY(embeddedVideoView);
    BM_RELEASE_SAFELY(animatedArray);
}

- (void)setMedias:(NSArray *)allMedia {
    [timer invalidate];
    timer = nil;
    [self cancelDataLoaders];
    if (allMedia.count == 0) {
        [self setMedia:nil];
    } else {
        [self setMedia:allMedia[0]];
        if (allMedia.count > 1) {
            BMTimerInfo *timerInfo = [BMTimerInfo new];
            timerInfo.target = self;
            timerInfo.userInfo = allMedia;
            timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:[self class] selector:@selector(timerFired:) userInfo:timerInfo repeats:YES];
        }
    } 
    if (self.useFullScreenImages) {
        //Load the full size images in the background
        for (id <BMMediaContainer> m in allMedia) {
            if (m != self.media) {
                [self loadFullSizeImageForMedia:m];
            }
        }
    }
}

- (BMEmbeddedVideoView *)embeddedVideoView {
    if (!embeddedVideoView) {
        embeddedVideoView = [[BMEmbeddedVideoView alloc] initWithFrame:self.bounds];
        embeddedVideoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return embeddedVideoView;
}

- (void)stopLoading {
    [super stopLoading];
    [embeddedVideoView stopLoading];
}

- (void)setShowActivity:(BOOL)show {
    [super setShowActivity:show];
    [embeddedVideoView setShowActivity:show];
}

- (void)setMedia:(id <BMMediaContainer>)displayMedia {
    [self setMedia:displayMedia animated:NO];
}

- (void)setMedia:(id <BMMediaContainer>)displayMedia animated:(BOOL)animated {
    [self setMedia:displayMedia animated:animated showPlaceHolder:YES];
}

- (void)setMedia:(id <BMMediaContainer>)displayMedia animated:(BOOL)animated showPlaceHolder:(BOOL)showPlaceHolder {
    if (media != displayMedia) {
        [self pushAnimated:animated];
        media = displayMedia;
        
        BMMediaKind mediaKind = (displayMedia ? displayMedia.mediaKind : BMMediaKindUnknown);
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:BM_SLOW_TRANSITION_DURATION];
        }
        
        if (mediaKind == BMMediaKindVideo && self.useEmbeddedVideoView) {
            
            //Show youtube thumbnail
            if (self.imageView.superview) {
                [self.imageView removeFromSuperview];
            }
            if (!self.embeddedVideoView.superview) {
                [embeddedVideoView setShowActivity:self.showActivity];
                [self addSubview:embeddedVideoView];
            }
            
            [embeddedVideoView setUrl:[BMStringHelper urlStringFromString:displayMedia.url]];
            //[embeddedVideoView setEntryId:displayMedia.entryId];
            
        } else {
            
            if (embeddedVideoView) {
                [embeddedVideoView removeFromSuperview];
            }
            if (!self.imageView.superview) {
                [self addSubview:self.imageView];
            }
            
            NSURL *url = displayMedia ? [BMStringHelper urlFromString:displayMedia.thumbnailImageUrl] : nil;
            
            if (self.useFullScreenImages && displayMedia) {
                NSString *urlString = displayMedia.midSizeImageUrl;
                if (urlString == nil && displayMedia.mediaKind == BMMediaKindPicture) {
                    urlString = displayMedia.url;
                }
                
                NSURL *fullUrl = [BMStringHelper urlFromString:urlString];
                if (fullUrl) {
                    url = fullUrl;
                }
            }
            [self setUrl:url];
            if (self.overlayDisabled) {
                [self.thumbnailView setMediaKind:BMMediaKindUnknown];
            } else {
                [self.thumbnailView setMediaKind:mediaKind];
            }
            
            if (url) {
                [self startLoadingByShowingPlaceHolder:showPlaceHolder];
            } else {
                if (displayMedia || !self.ignorePlaceHolderForNilMedia) {
                    [self setImage:self.placeHolderImage];
                } else {
                    [self setImage:nil];
                }
            }
            
            if (self.useFullScreenImages && displayMedia) {
                [self loadFullSizeImageForMedia:displayMedia];
            }
        }
        if (animated) {
            [UIView commitAnimations];
        }
        
        [self.delegate asyncLoadingMediaThumbnailButton:self changedMedia:media animated:animated];
    }
}

- (void)setImage:(UIImage *)theImage {
    BOOL animated = [self popAnimated];
    [self setImage:theImage animated:animated];
}

#pragma mark - BMAsyncDataLoaderDelegate

- (void)asyncDataLoader:(BMAsyncDataLoader *)dataLoader didFinishLoadingWithError:(NSError *)error {
    
    if ([dataLoaders containsObject:dataLoader]) {
        id <BMMediaContainer> mediaContainer = dataLoader.context;
        if (self.media == mediaContainer) {
            UIImage *image = [UIImage bmImageWithData:(NSData *)dataLoader.object];
            [self setImage:image animated:YES];
        }
        [dataLoaders removeObject:dataLoader];
    } else {
        if (error) {
            LogWarn(@"Failed loading image for URL: %@: %@", dataLoader.url, error);
            if (!self.image) {
                [self setImage:self.placeHolderImage animated:YES];
            }
        } else {
            UIImage *theImage = (UIImage *)dataLoader.object;
            [self setImage:theImage animated:YES];
        }
    }
    [self.activityIndicator stopAnimating];
}

@end

@implementation BMAsyncLoadingMediaThumbnailButton(Private)

+ (void)timerFired:(NSTimer *)theTimer {
    BMTimerInfo *timerInfo = [theTimer userInfo];
    BMAsyncLoadingMediaThumbnailButton *target = timerInfo.target;
    NSArray *allMedia = timerInfo.userInfo;
    [target setNextMedia:allMedia];
}

- (void)setNextMedia:(NSArray *)allMedia {
    NSUInteger currentIndex = [allMedia indexOfObjectIdenticalTo:self.media];
    
    if (currentIndex >= (allMedia.count - 1)) {
        currentIndex = 0;
    } else {
        currentIndex++;
    }
    
    id <BMMediaContainer> nextMedia = currentIndex < allMedia.count ? allMedia[currentIndex] : nil;
    [self setMedia:nextMedia animated:YES showPlaceHolder:NO];
}

- (BMMediaThumbnailView *)thumbnailView {
    if ([self.imageView isKindOfClass:[BMMediaThumbnailView class]]) {
        return (BMMediaThumbnailView *)self.imageView;
    } else {
        return nil;
    }
}

- (void)setImage:(UIImage *)theImage animated:(BOOL)animated {
    BMMediaThumbnailView *tv = self.thumbnailView;
    if (animated && tv != nil) {
        [tv crossfadeToImage:theImage];
    } else {
        [super setImage:theImage];
    }
}

- (BOOL)popAnimated {
    BOOL animated = NO;
    if (animatedArray.count > 0) {
        NSNumber *n = animatedArray[0];
        animated = [n boolValue];
        [animatedArray removeObjectAtIndex:0];
    }
    return animated;
}

- (void)pushAnimated:(BOOL)animated {
    [animatedArray addObject:@(animated)];
}

- (void)cancelDataLoaders {
    for (BMAsyncDataLoader *dataLoader in dataLoaders) {
        [dataLoader cancelLoading];
        dataLoader.delegate = nil;
    }
    [dataLoaders removeAllObjects];
}

- (void)loadFullSizeImageForMedia:(id <BMMediaContainer>)mediaContainer {
    NSString *theUrl = mediaContainer.midSizeImageUrl;
    if (mediaContainer.mediaKind == BMMediaKindPicture && !theUrl) {
        theUrl = mediaContainer.url;
    }
    if (theUrl && ![[BMURLCache sharedCache] hasImageForURL:theUrl fromDisk:YES]) {
        BMAsyncDataLoader *dataLoader = [[BMAsyncDataLoader alloc] initWithURLString:theUrl];
        dataLoader.context = mediaContainer;
        dataLoader.delegate = self;
        [dataLoaders addObject:dataLoader];
        [dataLoader startLoading];
    }
}

- (void)setup {
    if (!animatedArray) {
        animatedArray = [NSMutableArray new];
    }
    if (!dataLoaders) {
        dataLoaders = [NSMutableArray new];
    }
}

@end


