//
//  NSSet+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 4/7/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "NSSet+BMCommons.h"

@implementation NSSet (BMCommons)

@end


@implementation NSMutableSet(BMCommons)

- (void)bmSafeAddObject:(id)object {
    if (object) {
        [self addObject:object];
    }
}

@end

@implementation NSMutableOrderedSet(BMCommons)

- (void)bmSafeAddObject:(id)object {
    if (object) {
        [self addObject:object];
    }
}

@end