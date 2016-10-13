//
//  BMAsyncLoadingMediaContainer.m
//  BMCommons
//
//  Created by Werner Altewischer on 19/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMAsyncMediaContainerLoader.h"
#import <BMCore/BMStringHelper.h>
#import <BMCore/BMAsyncDataLoader.h>
#import <BMCore/BMMIMEType.h>
#import <BMMedia/BMMedia.h>

@interface BMAsyncMediaContainerLoader()<BMAsyncDataLoaderDelegate, BMMediaContainerDelegate>

@end

@interface BMAsyncMediaContainerLoader (Private) 

- (BOOL)startLoadingFromUrl:(NSString *)url;
- (BMAsyncDataLoader *)newDataLoader;

@end

@implementation BMAsyncMediaContainerLoader {
	BMAsyncDataLoader *mediaLoader;
	id<BMMediaContainer> media;
	
	BOOL loading;
	BOOL failedLoading;
	BOOL completedLoading;
	NSString *loaderUrl;
	
	UIImage *successImage;
	UIImage *errorImage;
}

static UIImage *defaultErrorImage = nil;

@synthesize loading;
@synthesize failedLoading;
@synthesize completedLoading;
@synthesize media;
@synthesize errorImage;

#pragma mark -
#pragma mark Initialization and deallocation

+ (void)setDefaultErrorImage:(UIImage *)image {
	if (image != defaultErrorImage) {
		defaultErrorImage = image;
	}
}

- (id)initWithMedia:(id <BMMediaContainer>)theMedia{
	if ((self = [self init])) {
		self.media = theMedia;
	}
	return self;
}

- (id)init {
	if ((self = [super init])) {
        BMMediaCheckLicense();
	}
	return self;
}


- (void)dealloc {
	mediaLoader.delegate = nil;
}

#pragma mark -
#pragma mark MediaContainerLoader implementation

- (BOOL)startLoading {
	return [self startLoadingFromUrl:media.url];
}

- (void)stopLoading {
	mediaLoader.delegate = nil;
	[mediaLoader cancelLoading];
	mediaLoader = nil;
	loading = NO;
}

- (BOOL)startLoadingThumbnailImage {
	return [self startLoadingFromUrl:self.media.thumbnailImageUrl];
}

- (BOOL)startLoadingMidSizeImage {
	return [self startLoadingFromUrl:self.media.midSizeImageUrl];
}

#pragma mark -
#pragma mark Custom getters/setters

- (UIImage *)thumbnailImage {
	UIImage *thumbnail = nil;
	if (![self.media isThumbnailImageLoaded] && [self failedLoading]) {
		//Could not load image: show error image
		thumbnail = self.errorImage;
	} else {
		thumbnail = self.media.thumbnailImage;
		if (!thumbnail && self.completedLoading) {
			thumbnail = self.errorImage;
		}
	}
	return thumbnail;
}

- (void)setMedia:(id <BMMediaContainer>)theMedia {
	if (media != theMedia) {
		[media removeDelegate:self];
		media = theMedia;
		[media addDelegate:self];
	}
}

/*
#pragma mark -
#pragma mark Message forwarding for the media container

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.media respondsToSelector:[anInvocation selector]]) {
		[anInvocation invokeWithTarget:self.media];
	} else {
		[super forwardInvocation:anInvocation];
	}
}	
	
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
		signature = [(NSObject *)self.media methodSignatureForSelector:selector];
    }
    return signature;
}

- (BOOL)conformsToProtocol:(Protocol *)protocol {
	if ([self.media conformsToProtocol:protocol]) {
		return YES;
	}
	return [super conformsToProtocol:protocol];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	if ([self.media respondsToSelector:aSelector]) {
		return YES;
	}
	return [super respondsToSelector:aSelector];
}
*/

#pragma mark -
#pragma mark Public methods


- (UIImage *)errorImage {
	if (errorImage) {
		return errorImage;
	} else {
		return defaultErrorImage;
	}
}

#pragma mark -
#pragma mark Protected methods

- (void)asyncDataLoader:(BMAsyncDataLoader *)dataLoader didFinishLoadingWithObject:(NSObject *)object {
	NSData *mediaData = (NSData *)object;
    NSString *ext = [loaderUrl pathExtension];
    if ([BMStringHelper isEmpty:ext]) {
        BMMIMEType *mimeType = [BMMIMEType mimeTypeForContentType:dataLoader.mimeType];
        ext = mimeType.fileExtensions.count > 0 ? (mimeType.fileExtensions)[0] : nil;
    }
	if ([loaderUrl isEqual:self.media.thumbnailImageUrl]) {
		[self.media setThumbnailImageData:mediaData withExtension:ext];
	} else if ([loaderUrl isEqual:self.media.midSizeImageUrl]) {
		[self.media setMidSizeImageData:mediaData withExtension:ext];
	} else {
		[self.media setData:mediaData withExtension:ext];
	}
	
	LogDebug(@"Media was loaded successfully for url: %@", loaderUrl);
	
	loading = NO;
	failedLoading = NO;
	completedLoading = YES;
	
	loaderUrl = nil;
}

- (void)asyncDataLoader:(BMAsyncDataLoader *)dataLoader didFinishLoadingWithError:(NSError *)error {
	LogWarn(@"Media could not be loaded: %@", error);
	loading = NO;
	failedLoading = YES;
	completedLoading = YES;
	loaderUrl = nil;
}

#pragma mark -
#pragma mark MediaContainerDelegate implementation

- (void)mediaContainerDidUpdate:(id <BMMediaContainer>)mediaContainer {
	//Do nothing
}

- (void)mediaContainerWasDeleted:(id <BMMediaContainer>)mediaContainer {
	if (mediaContainer == self.media) {
		[self stopLoading];
		self.media = nil;
	}
}

@end


@implementation BMAsyncMediaContainerLoader (Private) 

- (BMAsyncDataLoader *)newDataLoader {
	return [BMAsyncDataLoader new];
}

- (BOOL)startLoadingFromUrl:(NSString *)url {
	NSURL *mediaURL = [BMStringHelper urlFromString:url];
	if (!self.isLoading && mediaURL) {
		//The media loader release call cancels any open connections
		mediaLoader = [[BMAsyncDataLoader alloc] initWithURLString:url];
		mediaLoader.delegate = self;
		
		loaderUrl = url;
		loading = YES;
		failedLoading = NO;
		completedLoading = NO;
		[mediaLoader startLoading];
		return YES;
	} else {
		return NO;
	}
}

@end