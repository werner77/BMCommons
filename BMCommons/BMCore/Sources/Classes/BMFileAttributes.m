//
//  BMFileAttributes.m
//  BMCommons
//
//  Created by Werner Altewischer on 13/08/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "BMFileAttributes.h"


@interface BMFileAttributes()

@end

@implementation BMFileAttributes

+ (instancetype)fileAttributesForFileAtPath:(NSString *)filePath fileSize:(long long)fileSize modificationDate:(NSDate *)modificationDate pinned:(BOOL)pinned expirationTimeInterval:(NSTimeInterval)expirationTime {
    BMFileAttributes *ret = [self new];
    ret.filePath = filePath;
    ret.fileSize = fileSize;
    ret.modificationDate = modificationDate;
    ret.pinned = pinned;
    ret.expirationTimeInterval = expirationTime;
    return ret;
}

- (BOOL)isExpiredWithInterval:(NSTimeInterval)expirationInterval {
    return [self.modificationDate timeIntervalSinceNow] < -expirationInterval;
}

- (BOOL)isExpired {
    return [self isExpiredWithInterval:self.expirationTimeInterval];
}

@end