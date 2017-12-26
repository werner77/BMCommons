//
//  BMSortedSetTestCase.m
//  BMCommons_Tests
//
//  Created by Werner Altewischer on 26/12/2017.
//  Copyright © 2017 Werner Altewischer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <BMCommons/BMSortedSet.h>

@interface BMSortedSetTestCase : XCTestCase

@end

@implementation BMSortedSetTestCase

- (void)testInitialization {
    BMSortedSet *set1 = [[BMSortedSet alloc] init];
    [set1 addObject:@"aap"];
    XCTAssertNotNil([set1 member:@"aap"]);
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:set1];
    XCTAssertNotNil(data);
    
    BMSortedSet *set2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqual(1, set2.count);
    XCTAssertNotNil([set2 member:@"aap"]);
    
    BMSortedSet *set3 = [[BMSortedSet alloc] initWithCapacity:16];
    
    BMSortedSet *set4 = [[BMSortedSet alloc] initWithObjects:@"noot", nil];
    
    for (BMSortedSet *set in @[set1, set2, set3, set4]) {
        [set addObject:@"schaap"];
        XCTAssertNotNil([set member:@"schaap"]);
    }
}

- (void)testSorting {
    BMSortedSet *set1 = [[BMSortedSet alloc] init];
    set1.sortSelector = @selector(compare:);
    
    NSArray *input = @[@"aap", @"noot", @"mies", @"wim", @"zus", @"jet"];
    for (NSString *s in input) {
        [set1 addObject:s];
    }
    
    NSArray *expected = @[@"aap", @"jet", @"mies", @"noot", @"wim", @"zus"];
    
    XCTAssertTrue([expected isEqualToArray:set1.allObjects]);
    
    BMSortedSet *set2 = [set1 copy];
    XCTAssertTrue([expected isEqualToArray:set2.allObjects]);
    
    [set2 addObject:@"horse"];
    
    NSArray *expected1 = @[@"aap", @"horse", @"jet", @"mies", @"noot", @"wim", @"zus"];
    
    XCTAssertTrue([expected1 isEqualToArray:set2.allObjects]);
}

@end
