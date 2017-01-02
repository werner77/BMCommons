//
//  BMApp.h
//  BMCommons
//
//  Created by Werner Altewischer on 9/25/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMSingleton.h>

/**
 Class with information about static identifiers of the app defined in the application plist (display name, identifier, version, etc).
 */
@interface BMApp : NSObject {
    NSBundle * _bundle;
}

BM_DECLARE_DEFAULT_SINGLETON

@property (strong, nonatomic, readonly) NSBundle *bundle;

- (NSString *)displayName;
- (NSString *)name;
- (NSString *)version;
- (NSString *)build;
- (NSString *)identifier;
- (NSString *)fullVersion;

@end
