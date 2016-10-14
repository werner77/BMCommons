//
//  NSUserDefaults+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 4/7/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "NSUserDefaults+BMCommons.h"

@implementation NSUserDefaults (BMCommons)

- (void)bmSafeSetObject:(id)object forKey:(NSString *)key {
    if (key) {
        if (object) {
            [self setObject:object forKey:key];
        } else {
            [self removeObjectForKey:key];
        }
    }
}

@end
