//
//  BMApp.h
//  BMCommons
//
//  Created by Werner Altewischer on 9/25/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMSingleton.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Class with information about static identifiers of the app defined in the application plist (display name, identifier, version, etc).
 */
@interface BMApp : NSObject

BM_DECLARE_DEFAULT_SINGLETON

@property (strong, nonatomic, readonly) NSBundle *bundle;

/**
 * The display name for the app
 */
- (nullable NSString *)displayName;

/**
 * The name for the app
 */
- (nullable NSString *)name;

/**
 * The version for the app
 */
- (nullable NSString *)version;

/**
 * The build number for the app
 */
- (nullable NSString *)build;

/**
 * The bundle identifier for the app
 */
- (nullable NSString *)identifier;

/**
 * The full version containing version and build (if defined).
 */
- (nullable NSString *)fullVersion;

@end

NS_ASSUME_NONNULL_END
