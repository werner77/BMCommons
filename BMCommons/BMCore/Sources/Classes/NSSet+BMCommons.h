//
//  NSSet+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 4/7/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (BMCommons)

@end

@interface NSMutableSet(BMCommons)

- (void)bmSafeAddObject:(id)object;

@end

@interface NSMutableOrderedSet(BMCommons)

- (void)bmSafeAddObject:(id)object;

@end

