//
//  BMCacheTestCase.m
//  BMCommons
//
//  Created by Werner Altewischer on 29/01/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "BMCacheTestCase.h"
#import <BMCommons/BMCache.h>

@implementation BMCacheTestCase

- (void)testCache {
    BMCache *cache = [BMCache new];
    cache.maxCount = 4;
    
    [cache setObject:@"aap" forKey:@"1"];
    [cache setObject:@"noot" forKey:@"2"];
    [cache setObject:@"mies" forKey:@"3"];
    [cache setObject:@"boom" forKey:@"4"];
    
    //Should now be the newest entity
    [cache objectForKey:@"1"];
    
    [cache setObject:@"tak" forKey:@"5"];
    
    XCTAssertTrue(cache.count == 3, @"Expected cache count to be half + 1");
    XCTAssertTrue([cache objectForKey:@"1"] != nil, @"Expected '1' to still be in the cache");
    XCTAssertTrue([cache objectForKey:@"2"] == nil, @"Expected '2' to not be in the cache");
    XCTAssertTrue([cache objectForKey:@"3"] == nil, @"Expected '3' to not be in the cache");
}

@end
