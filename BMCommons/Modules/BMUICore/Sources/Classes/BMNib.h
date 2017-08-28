//
//  BMNib.h
//  BMCommons
//
//  Created by Werner Altewischer on 29/01/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BMNib;

typedef void (^BMNibConfigurationBlock)(BMNib *nib);

@interface BMNib : UINib

+ (BMNib *)nibWithNibName:(NSString *)name bundle:(nullable NSBundle *)bundleOrNil;
+ (BMNib *)nibWithData:(NSData *)data bundle:(nullable NSBundle *)bundleOrNil;

/**
 Constructs a nib with the specified class of objects.
 
 This is to reuse nib caching implementation (used by UICollectionView/UITableView) for views (UICollectionViewCells/UITableViewCells) that are not actually in an archived nib. The UINib will just alloc-init objects from the specified class and return them.
 */
+ (BMNib *)nibWithObjectClass:(Class)clazz;

/**
 * Sets the configuration block to perform to configure the nib for the specified name when instantiated.
 *
 * If nibName == nil, this supplied configuration block is used for all nibs that don't match any other registered name.
 *
 * @param block The configuration block
 * @param nibName The name of the nib
 * @see [BMNib nibWithNibName:bundle:]
 */
+ (void)setConfigurationBlock:(nullable BMNibConfigurationBlock)block forNibWithName:(nullable NSString *)nibName;

/**
 * If set to true the cache warmup is performed in a background thread. For this to work the init/dealloc methods should be thread safe.
 * UIViews are allowed to be instantiated in a background thread. If you are sure your views don't do custom non-thread safe logic inside their init/dealloc methods you may set this to true.
 *
 * Defaults to false.
 */
@property (assign) BOOL warmupCacheInBackground;

/**
 Set to a value higher than 0 (which is the default) to enable precaching of nib objects up to the specified size before the first allocation.
 
 Set this to the maximum number of objects that will simultaneously be allocated (e.g. UICollectionViewCells or UITableViewCells that are visible at the same time).
 */
@property (assign) NSUInteger preCacheSize;

/**
 * Set to a value higher than 0 to always at least pre-allocate the specified amount of objects to avoid hickups when new cells have to be instantiated.
 *
 * When the cache pool size decreases below this threshold automatically new objects will be instantiated and added to the precache pool.
 */
@property (assign) NSUInteger cacheSize;

/**
 Clears the nib cache.
 */
- (void)clearCache;

@end

NS_ASSUME_NONNULL_END
