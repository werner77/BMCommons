//
//  BMAsyncImageLoader.m
//  BMCommons
//
//  Created by Werner Altewischer on 20/05/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAsyncImageLoader.h>
#import <BMCommons/BMURLCache.h>

#if TARGET_OS_IPHONE
#import <BMCommons/UIImage+BMCommons.h>
#endif

@implementation BMAsyncImageLoader

#if TARGET_OS_IPHONE

- (UIImage *)image {
	UIImage *returnImage = nil;
	if ([self.object isKindOfClass:[UIImage class]]) {
		returnImage = (UIImage *)self.object;
	} 
	return returnImage;
}

- (void)setImage:(UIImage *)theImage {	
	self.object = theImage;
}

- (NSObject *)cachedObject {
	BMURLCache *cache = self.effectiveCache;
	NSURL *theUrl = self.url;
	NSString *urlString = [theUrl absoluteString];
	UIImage *image = nil;
	if (theUrl) {
		image = [cache imageForURL:urlString];
	}
	return image;
}

- (NSObject *)objectFromData:(NSData *)theData withCache:(BMURLCache *)cache cacheKey:(NSString *)key {
    UIImage *image = [UIImage bmImageWithData:theData];
    if (image && key) {
        [cache storeImage:image forKey:key];
    }
    return image;
}

- (void)releaseMemory {
}

/**
 Whether the object for the specified URL is on disk, in memory or not cached at all.
 */
- (BMAsyncDataLoaderCacheState)cacheState {
    if ([self.effectiveCache hasImageForURL:self.urlString fromDisk:NO]) {
        return BMAsyncDataLoaderCacheStateMemory;
    } else {
        return [super cacheState];
    }
}

#endif

@end


