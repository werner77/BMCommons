//
//  BMSortedArrayTestCase.m
//  BMCommons_Tests
//
//  Created by Werner Altewischer on 25/12/2017.
//  Copyright © 2017 Werner Altewischer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <BMCommons/BMSortedArray.h>

@interface BMSortedArrayTestCase : XCTestCase

@end

@implementation BMSortedArrayTestCase

- (void)testInitialization {
    BMSortedArray *array1 = [[BMSortedArray alloc] init];
    [array1 addObject:@"boom"];
    XCTAssertEqual(1, array1.count);
    
    BMSortedArray *array2 = [[BMSortedArray alloc] initWithCapacity:10];
    BMSortedArray *array3 = [[BMSortedArray alloc] initWithArray:@[@"aap", @"noot", @"mies"]];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array1];
    
    XCTAssertNotNil(data);
    
    BMSortedArray *array4 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertNotNil(array4);
    XCTAssertEqual(1, array4.count);
    
    for (NSMutableArray *array in @[array1, array2, array3, array4]) {
        NSUInteger currentCount = array.count;
        [array addObject:@"bla"];
        
        XCTAssertEqual(currentCount + 1, array.count);
        XCTAssertTrue([array containsObject:@"bla"]);
    }
}

- (void)testSorting {
    BMSortedArray *array1 = [[BMSortedArray alloc] init];
    array1.sortSelector = @selector(compare:);
    NSArray *input = @[@"aap", @"noot", @"mies", @"wim", @"zus", @"jet"];
    for (NSString *s in input) {
        [array1 addObject:s];
    }
    
    NSArray *expected = @[@"aap", @"jet", @"mies", @"noot", @"wim", @"zus"];
    
    XCTAssertTrue([expected isEqualToArray:array1]);
    
    BMSortedArray *array2 = [array1 copy];
    XCTAssertTrue([expected isEqualToArray:array2]);
    
    [array2 addObject:@"pomp"];
    
    NSArray *expected1 = @[@"aap", @"jet", @"mies", @"noot", @"pomp", @"wim", @"zus"];
    
    XCTAssertTrue([expected1 isEqualToArray:array2]);
}

- (void)testRemoval {
    BMSortedArray *array1 = [[BMSortedArray alloc] initWithArray:@[@"aap", @"noot", @"mies", @"wim", @"zus", @"jet"]];
    array1.sortSelector = @selector(compare:);
    
    NSArray *expected = @[@"aap", @"jet", @"mies", @"noot", @"wim", @"zus"];
    
    XCTAssertTrue([expected isEqualToArray:array1]);
    
    [array1 removeObject:@"mies"];
    
    NSArray *expected1 = @[@"aap", @"jet", @"noot", @"wim", @"zus"];
    
    XCTAssertTrue([expected1 isEqualToArray:array1]);
}


@end
