//
//  BMNib.h
//  BMCommons
//
//  Created by Werner Altewischer on 29/01/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMNib : UINib

+ (BMNib *)nibWithNibName:(NSString *)name bundle:(NSBundle *)bundleOrNil;
+ (BMNib *)nibWithData:(NSData *)data bundle:(NSBundle *)bundleOrNil;

/**
 Constructs a nib with the specified class of objects.
 
 This is to reuse nib caching implementation (used by UICollectionView/UITableView) for views (UICollectionViewCells/UITableViewCells) that are not actually in an archived nib. The UINib will just alloc-init objects from the specified class and return them.
 */
+ (BMNib *)nibWithObjectClass:(Class)clazz;

/**
 Returns the default precache size for all nibs with the specified nib name.
 
 This is used by BMViewFactory.
 
 @see BMViewFactory
 */
+ (NSUInteger)defaultPrecacheSizeForNibName:(NSString *)nibName;


/**
 Sets the default precache size for all nibs with the specified nib name.
 */
+ (void)setDefaultPrecacheSize:(NSUInteger)preCacheSize forNibName:(NSString *)nibName;

/**
 Set to a value higher than 0 (which is the default) to enable precaching of nib objects up to the specified size.
 
 Set this to the maximum number of objects that will simultaneously be allocated (e.g. UICollectionViewCells or UITableViewCells that are visible at the same time).
 */
@property (nonatomic, assign) NSUInteger preCacheSize;

/**
 Populates the nib cache for faster loading of nibs.
 
 This is also done automatically after the first call to instantiateWithOwner or when the precacheSize is set to a value higher than 0.
 */
- (void)populateCache;

/**
 Clears the nib cache.
 */
- (void)clearCache;

@end
