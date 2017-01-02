//
//  BMMediaItemStorage.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/26/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMURLCacheMediaStorage.h>
#import <BMCommons/BMURLCache.h>
#import <BMCommons/UIImage+BMCommons.h>
#import <BMCommons/UIImageToJPEGDataTransformer.h>

@implementation BMURLCacheMediaStorage {
    BMURLCache *_cache;
}

@synthesize cache = _cache;

BM_SYNTHESIZE_DEFAULT_SINGLETON

- (BMURLCache *)cache {
    if (_cache) {
        return _cache;
    }
    return [BMURLCache cacheWithName:NSStringFromClass([self class]) persistent:YES];
}

- (NSData *)dataForUrl:(NSString *)urlString {
    return urlString == nil ? nil : [self.cache dataForURL:urlString];
}

- (void)setData:(NSData *)theData forUrl:(NSString *)theUrl {
    BMURLCache *cache = self.cache;
    
	if (theData) {
		[cache storeData:theData forURL:theUrl];
		[cache pinDataForURL:theUrl];
	} else {
		[cache removeURL:theUrl fromDisk:YES];
	}
}

- (void)moveDataFromFile:(NSString *)filePath toUrl:(NSString *)theUrl {
    BMURLCache *cache = self.cache;
    [cache moveDataFromPath:filePath toURL:theUrl];
	[cache pinDataForURL:theUrl];
}

- (BOOL)hasDataForUrl:(NSString *)theUrl {
    return theUrl != nil && [self.cache hasDataForURL:theUrl];
}

- (void)moveDataForUrl:(NSString *)oldUrl toUrl:(NSString *)newUrl {
    [self.cache moveDataForURL:oldUrl toURL:newUrl];
}

- (UIImage *)imageForUrl:(NSString *)theUrl {
    UIImage *image = nil;
	
	if (theUrl) {
        BMURLCache *cache = self.cache;
		image = [cache imageForURL:theUrl];
		
		if (!image) {
			NSData *imageData = [self dataForUrl:theUrl];
			image = [UIImage bmImageWithData:imageData];
			if (image) {
				[cache storeImage:image forURL:theUrl];
			}
		}
	}
	return image;
}

- (NSString *)filePathForUrl:(NSString *)urlString {
    BMURLCache *cache = self.cache;
    NSString *path = nil;
    if (urlString != nil) {
        if ([cache hasDataForURL:urlString]) {
            path = [cache cachePathForURL:urlString];
        }
    }
    return path;
}

- (void)releaseMemoryForUrl:(NSString *)theUrl {
    [self.cache removeURL:theUrl fromDisk:NO];
}

- (NSString *)createUniqueLocalUrlWithExtension:(NSString *)extension {
    return [self.cache uniqueLocalURLWithExtension:extension];
}

- (BOOL)isLocalUrl:(NSString *)url {
    return [self.cache isLocalURL:url];
}

@end
