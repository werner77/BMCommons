//
//  BMFileAttributes.h
//  BMCommons
//
//  Created by Werner Altewischer on 13/08/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCoreObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Class wrapping attributes for a file on the local file system.
 */
@interface BMFileAttributes : BMCoreObject

/**
 * Whether or not the file is pinned to be protected against deletion.
 */
@property (assign) BOOL pinned;

/**
 * The last modification date of the file.
 */
@property (nullable, strong) NSDate *modificationDate;

/**
 * The size of the file in bytes.
 */
@property (assign) long long fileSize;

/**
 * The path to the file.
 */
@property (strong) NSString *filePath;

/**
 * The expiration time interval for the file (e.g. in case of caching).
 */
@property (assign) NSTimeInterval expirationTimeInterval;

+ (instancetype)fileAttributesForFileAtPath:(NSString *)filePath fileSize:(long long)fileSize modificationDate:(nullable NSDate *)modificationDate pinned:(BOOL)pinned expirationTimeInterval:(NSTimeInterval)expirationTimeInterval;

/**
 * Whether or not the file is expired with the specified interval. Returns true if the last modification date was longer ago then the interval.
 */
- (BOOL)isExpiredWithInterval:(NSTimeInterval)expirationInterval;

/**
 * Returns [BMFileAttributes isExpiredWithInterval:] with the expirationTimeInterval set in this object.
 */
- (BOOL)isExpired;

@end

NS_ASSUME_NONNULL_END
