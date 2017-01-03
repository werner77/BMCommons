//
//  BMApp.m
//  BMCommons
//
//  Created by Werner Altewischer on 9/25/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMApp.h>
#import <BMCommons/BMStringHelper.h>

@implementation BMApp

@synthesize bundle = _bundle;

BM_SYNTHESIZE_DEFAULT_SINGLETON

- (id)init {
    if ((self = [super init])) {
        _bundle = [NSBundle mainBundle];
    }
    return self;
}

- (NSString *)displayName {
    return [[self.bundle infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

- (NSString *)name {
    return [[self.bundle infoDictionary] objectForKey:@"CFBundleName"];
}

- (NSString *)version {
    NSString *version = [[self.bundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (version == nil) {
        version = self.build;
    }
    return [BMStringHelper filterNilString:version];
}

- (NSString *)build {
    return [BMStringHelper filterNilString:[[self.bundle infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
}

- (NSString *)identifier {
    return [[self.bundle infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
}

- (NSString *)fullVersion {
    NSString *version = self.version;
    NSString *build = self.build;
    if ([version isEqualToString:build]) {
        return version;
    } else {
        return [NSString stringWithFormat:@"%@ build %@", self.version, self.build];
    }
}

@end
