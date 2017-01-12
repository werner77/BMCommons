//
//  NSSet+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 4/7/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "NSSet+BMCommons.h"
#import "NSObject+BMCommons.h"

@implementation NSSet (BMCommons)

- (NSString *)bmPrettyDescription {
    NSMutableString *ret = [NSMutableString new];
    [ret appendString:@"["];
    BOOL first = YES;
    for (id obj in self) {
        if (first) {
            first = NO;
        } else {
            [ret appendString:@", "];
        }
        [ret appendString:[obj bmPrettyDescription]];
    }
    [ret appendString:@"]"];
    return ret;
}

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