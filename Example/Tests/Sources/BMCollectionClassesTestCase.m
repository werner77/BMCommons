//
//  BMOrderedDictionaryTestCase.m
//  BMCommons
//
//  Created by Werner Altewischer on 21/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "BMCollectionClassesTestCase.h"
#import <BMCommons/BMOrderedDictionary.h>
#import <BMCommons/BMFileBackedMutableArray.h>
#import <BMCommons/BMCache.h>

@implementation BMCollectionClassesTestCase

- (void)testOrderedDictionaryCoding {
    BMOrderedDictionary *dict = [BMOrderedDictionary new];
    
    [dict setObject:@"aap" forKey:@(10)];
    [dict setObject:@"noot" forKey:@(8)];
    [dict setObject:@"mies" forKey:@(20)];
    
    int i = 0;
    for (id key in dict) {
        id value = [dict objectForKey:key];
        if (i == 0) {
            XCTAssertEqualObjects(@10, key, @"Expected key to be correct");
            XCTAssertEqualObjects(@"aap", value, @"Expected value to be correct");
        } else if (i == 1) {
            XCTAssertEqualObjects(@8, key, @"Expected key to be correct");
            XCTAssertEqualObjects(@"noot", value, @"Expected value to be correct");
        } else if (i == 2) {
            XCTAssertEqualObjects(@20, key, @"Expected key to be correct");
            XCTAssertEqualObjects(@"mies", value, @"Expected value to be correct");
        }
        i++;
    }

    [NSKeyedArchiver setClassName:@"BMOrderedDictionary" forClass:[BMOrderedDictionary class]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];

    BMOrderedDictionary *otherDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertTrue(dict.count == otherDict.count, @"Expected counts to be equal");

    //this does not yet work unfortunately
    /**
    i = 0;
    for (id key in otherDict) {
        id value = [dict objectForKey:key];
        if (i == 0) {
            XCTAssertEqualObjects(@10, key, @"Expected key to be correct");
            XCTAssertEqualObjects(@"aap", value, @"Expected value to be correct");
        } else if (i == 1) {
            XCTAssertEqualObjects(@8, key, @"Expected key to be correct");
            XCTAssertEqualObjects(@"noot", value, @"Expected value to be correct");
        } else if (i == 2) {
            XCTAssertEqualObjects(@20, key, @"Expected key to be correct");
            XCTAssertEqualObjects(@"mies", value, @"Expected value to be correct");
        }
        i++;
    }
    */

    [otherDict removeAllObjects];
    
    XCTAssertTrue(otherDict.count == 0, @"Expected objects to be removed");
}

- (void)testFileBackedArray {
    @autoreleasepool {
        
        [[BMFileBackedMutableArray globalCache] clear];
        [[BMFileBackedMutableArray globalCache] setMaxMemoryUsage:20];
        
        BMFileBackedMutableArray *array = [[BMFileBackedMutableArray alloc] initWithCapacity:10];
        
        [array addObjectsFromArray:@[@"aap", @"noot", @"mies"]];
        
        int i = 0;
        for (id object in array) {
            if (i == 0) {
                XCTAssertTrue([@"aap" isEqual:object], @"Expected objects to be equal");
            } else if (i == 1) {
                XCTAssertTrue([@"noot" isEqual:object], @"Expected objects to be equal");
            } else if (i == 2) {
                XCTAssertTrue([@"mies" isEqual:object], @"Expected objects to be equal");
            }
            i++;
        }
        
        //Should truncate file
        
        NSUInteger fileSize = (NSUInteger)[array fileSize];
        
        [array replaceObjectAtIndex:2 withObject:@"miep"];
        
        XCTAssertTrue(fileSize == [array fileSize], @"Expected file size to remain the same");
        
        [array replaceObjectAtIndex:1 withObject:@"nootje"];
        
        [array removeObjectAtIndex:0];
        
        [array insertObject:@"aap" atIndex:0];
        
        [array insertObject:@"gorilla" atIndex:1];
        
        i = 0;
        for (id object in array) {
            if (i == 0) {
                XCTAssertTrue([@"aap" isEqual:object], @"Expected objects to be equal");
            } else if (i == 1) {
                XCTAssertTrue([@"gorilla" isEqual:object], @"Expected objects to be equal");
            } else if (i == 2) {
                XCTAssertTrue([@"nootje" isEqual:object], @"Expected objects to be equal");
            } else if (i == 3) {
                XCTAssertTrue([@"miep" isEqual:object], @"Expected objects to be equal");
            }
            i++;
        }
        
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        
        XCTAssertNotNil(data, @"Expected data to be serialized correctly");
        
        NSMutableArray *otherArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        XCTAssertTrue(array.count == otherArray.count, @"Expected counts to be equal");
        
        i = 0;
        for (id object in array) {
            if (i == 0) {
                XCTAssertTrue([@"aap" isEqual:object], @"Expected objects to be equal");
            } else if (i == 1) {
                XCTAssertTrue([@"gorilla" isEqual:object], @"Expected objects to be equal");
            } else if (i == 2) {
                XCTAssertTrue([@"nootje" isEqual:object], @"Expected objects to be equal");
            } else if (i == 3) {
                XCTAssertTrue([@"miep" isEqual:object], @"Expected objects to be equal");
            }
            i++;
        }
        
        [otherArray removeAllObjects];
        
        XCTAssertTrue(otherArray.count == 0, @"Expected objects to be removed");
        
        [array removeAllObjects];
        
        XCTAssertTrue(array.count == 0, @"Expected count to be zero");
        
        XCTAssertTrue([array fileSize] == 0, @"Expected filesize to be zero");

        array = nil;
        
    }
}

@end
