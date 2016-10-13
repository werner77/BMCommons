//
//  BMMediaStorage.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/26/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Storage for storing media data retrievable via URL as a key. 
 
 The key does not directly correspond to the underlying file/data but is merely a key to lookup the data. Implementations may choose their own storage mechanism, such as file, BMURLCache, CoreData, etc.
 */
@protocol BMMediaStorage<NSObject>

/**
 Returns true if and only if data exists within the storage for the supplied URL.
 */
- (BOOL)hasDataForUrl:(NSString *)theUrl;

/**
 Stores data for the supplied URL. 
 
 If data is nil it will remove the data.
 */
- (void)setData:(NSData *)theData forUrl:(NSString *)theUrl;

/**
 Moves the data from the specified filePath to this storage with the supplied URL as key.
 */
- (void)moveDataFromFile:(NSString *)filePath toUrl:(NSString *)theUrl;

/**
 Moves data for the old url to the new url.
 */
- (void)moveDataForUrl:(NSString *)oldUrl toUrl:(NSString *)newUrl;

/**
 Retrieves data for the supplied url, returns nil if not present.
 */
- (NSData *)dataForUrl:(NSString *)theUrl;

/**
 Returns an image for the supplied URL. 
 
 If no data is present or the data is not valid image data nil is returned.
 */
- (UIImage *)imageForUrl:(NSString *)theUrl;

/**
 Releases any memory that is held for caching the specified url. 
 
 Only memory is cleared, data remains on disk.
 */
- (void)releaseMemoryForUrl:(NSString *)theUrl;

/**
 Creates a new unique local URL with the supplied file extension. 
 
 You can use this URL to store new local data.
 */
- (NSString *)createUniqueLocalUrlWithExtension:(NSString *)extension;

/**
 Returns true if the supplied URL is a local url, false otherwise. 
 
 Local means an item stored within this cache and not elsewhere.
 */
- (BOOL)isLocalUrl:(NSString *)url;

/**
 Returns a filePath for retrieving the data from the local filesystem for the corresponding url.
 
 May return nil in case the data is not present on the local file system.
 */
- (NSString *)filePathForUrl:(NSString *)theUrl;

@end
