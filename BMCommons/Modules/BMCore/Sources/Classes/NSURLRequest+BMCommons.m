//
//  NSURLRequest+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 16/02/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "NSURLRequest+BMCommons.h"
#import <BMCommons/BMCore.h>
#import "NSData+BMEncryption.h"
#import <objc/runtime.h>
#import <BMCommons/BMSHA1Digest.h>
#import <BMCommons/NSObject+BMCommons.h>
#import <BMCommons/NSDictionary+BMCommons.h>
#import <BMCommons/BMCachingURLProtocol.h>

@implementation NSURLRequest (BMCommons)

- (void)bmSetTimeoutInterval:(NSTimeInterval)timeoutInterval {
    @try {
        [self setValue:@(timeoutInterval) forKey:@"timeoutInterval"];
    }
    @catch (NSException *exception) {
        LogWarn(@"Could not set NSURLRequest timeout: %@", exception);
    }
}

- (void)bmSetCachePolicy:(NSURLRequestCachePolicy)cachePolicy {
    @try {
        [self setValue:@(cachePolicy) forKey:@"cachePolicy"];
    }
    @catch (NSException *exception) {
        LogWarn(@"Could not set NSURLRequest cachePolicy: %@", exception);
    }
}

- (NSString *)bmDigest {
    //Calculate a hash for all the header fields
    return [self bmDigestByExcludingHeaders:nil includeBody:YES];
}

- (NSString *)bmDigestByIncludingHeaders:(NSArray *)includeHeaders includeBody:(BOOL)includeBody {
    
    BMDigest *digest = [BMDigest digestOfType:BMDigestTypeSHA1];
    
    NSDictionary *allHeaderFields = [self allHTTPHeaderFields];
    NSArray *allHeaderKeys = [[allHeaderFields allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSStringEncoding encoding = NSUTF8StringEncoding;
    
    [digest updateWithData:[self.HTTPMethod dataUsingEncoding:encoding] last:NO];
    [digest updateWithData:[self.URL.absoluteString dataUsingEncoding:encoding] last:NO];
    
    for (id key in allHeaderKeys) {
        NSString *keyString = [key bmCastSafely:[NSString class]];
        if (keyString != nil && [includeHeaders containsObject:keyString]) {
            @autoreleasepool {
                NSString *value = [[allHeaderFields objectForKey:keyString] bmCastSafely:[NSString class]];
                if (value != nil) {
                    [digest updateWithData:[key dataUsingEncoding:encoding] last:NO];
                    [digest updateWithData:[value dataUsingEncoding:encoding] last:NO];
                }
            }
        }
    }
    
    if (includeBody) {
        @autoreleasepool {
            NSData *body = [self HTTPBody];
            if (body.length > 0) {
                [digest updateWithData:body last:NO];
            }
        }
    }
    [digest updateWithData:nil last:YES];
    return [digest stringRepresentation];
    
}

- (NSString *)bmDigestByExcludingHeaders:(NSArray *)excludeHeaders includeBody:(BOOL)includeBody {
    NSMutableArray *headerKeys = [[[self allHTTPHeaderFields] allKeys] mutableCopy];
    [headerKeys removeObjectsInArray:excludeHeaders];
    return [self bmDigestByIncludingHeaders:headerKeys includeBody:includeBody];
}

- (BOOL)isBMURLCachingEnabled {
    return [BMCachingURLProtocol isCachingEnabledForRequest:self];
}

- (NSString *)bmRawDescription {
    NSMutableString *ret = [NSMutableString new];

    [ret appendFormat:@"%@ %@\n", [self HTTPMethod], self.URL];

    NSDictionary *allHeaderFields = [self allHTTPHeaderFields];
    for (id key in allHeaderFields) {
        [ret appendFormat:@"%@: %@\n", key, [allHeaderFields objectForKey:key]];
    }
    [ret appendFormat:@"\n%@\n", [[NSString alloc] initWithData:[self HTTPBody] encoding:NSUTF8StringEncoding]];
    return ret;
}

@end

@implementation NSMutableURLRequest (BMCommons)

- (void)setBMURLCachingEnabled:(BOOL)enabled {
    [BMCachingURLProtocol setCachingEnabled:enabled forRequest:self];
}

@end
