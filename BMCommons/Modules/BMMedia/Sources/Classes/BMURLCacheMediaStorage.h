//
//  BMMediaItemStorage.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/26/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaStorage.h>
#import <BMCommons/BMSingleton.h>

@class BMURLCache;

/**
 BMMediaStorage implementation using BMURLCache as underlying storage mechanism.
 */
@interface BMURLCacheMediaStorage : NSObject<BMMediaStorage>

BM_DECLARE_DEFAULT_SINGLETON

/**
 Set the cache implementation to use. 
 
 By default it uses a persistent cache (stored in the documents folder) with name equal to the name of this class.
 
 @see [BMURLCache cacheWithName:persistent:]
 */
@property (nonatomic, strong) BMURLCache *cache;

@end
