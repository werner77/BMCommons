//
//  BMMediaItem.h
//  BMCommons
//
//  Created by Werner Altewischer on 24/09/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaContainer.h>
#import <BMMedia/BMMediaStorage.h>

/**
 Abstract BMMediaContainer implementation, which relies for its property storage on NSCoding.
 
 For the media data storage such as video and image data an implementation of BMMediaStorage is used.
 */
@interface BMMediaItem : NSObject<BMMediaContainer, NSCoding> 

/**
 Sets the default storage to use if no explicit storage is set for the instance.
 
 Default is [BMURLCacheMediaStorage sharedInstance].
 */
+ (void)setDefaultStorage:(id <BMMediaStorage>)storage;
+ (id <BMMediaStorage>)defaultStorage;

/**
 The BMMediaStorage implementation to use for storing media data.
 
 By default the instance returned from [BMMediaItem defaultStorage] is used.
 */
@property (nonatomic, strong) id <BMMediaStorage> storage;

@end

@interface BMMediaItem(Protected)

/**
 Utility method for sub classes to convert a UIImage to NSData.
 */
- (NSData *)dataFromImage:(UIImage *)image;

@end