//
//  BMSortedDictionaryTestCase.m
//  BMCommons_Tests
//
//  Created by Werner Altewischer on 25/12/2017.
//  Copyright © 2017 Werner Altewischer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <BMCommons/BMSortedDictionary.h>

@interface BMSortedDictionaryTestCase : XCTestCase

@end

@implementation BMSortedDictionaryTestCase

- (void)testInitialization {
    BMSortedDictionary *dict1 = [[BMSortedDictionary alloc] init];
    dict1[@"aap"] = @"noot";
    XCTAssertNotNil(dict1[@"aap"]);
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict1];
    XCTAssertNotNil(data);
    
    BMSortedDictionary *dict2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqual(1, dict2.count);
    XCTAssertNotNil(dict2[@"aap"]);
    
    BMSortedDictionary *dict3 = [[BMSortedDictionary alloc] initWithCapacity:16];
    
    BMSortedDictionary *dict4 = [[BMSortedDictionary alloc] initWithObjects:@[@"noot"] forKeys:@[@"aap"]];
    
    for (BMSortedDictionary *dict in @[dict1, dict2, dict3, dict4]) {
        dict[@"teun"] = @"schaap";
        XCTAssertEqual(@"schaap", dict[@"teun"]);
    }
}

- (void)testSorting {
    BMSortedDictionary *dict1 = [[BMSortedDictionary alloc] init];
    dict1.sortSelector = @selector(compare:);
    
    NSArray *input = @[@"aap", @"noot", @"mies", @"wim", @"zus", @"jet"];
    for (NSString *s in input) {
        dict1[s] = [NSNull null];
    }
    
    NSArray *expected = @[@"aap", @"jet", @"mies", @"noot", @"wim", @"zus"];
    
    XCTAssertTrue([expected isEqualToArray:dict1.allKeys]);
    
    BMSortedDictionary *dict2 = [dict1 copy];
    XCTAssertTrue([expected isEqualToArray:dict2.allKeys]);
    
    dict2[@"horse"] = [NSNull null];
    
    NSArray *expected1 = @[@"aap", @"horse", @"jet", @"mies", @"noot", @"wim", @"zus"];
    
    XCTAssertTrue([expected1 isEqualToArray:dict2.allKeys]);
}

@end
