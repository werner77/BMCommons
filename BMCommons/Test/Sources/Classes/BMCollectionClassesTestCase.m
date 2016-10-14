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

- (void)testOrderedDictionary {
    BMOrderedDictionary *dict = [BMOrderedDictionary new];
    
    [dict setObject:@"aap" forKey:@(10)];
    [dict setObject:@"noot" forKey:@(8)];
    [dict setObject:@"mies" forKey:@(20)];
    
    int i = 0;
    for (id key in dict) {
        id value = [dict objectForKey:key];
        if (i == 0) {
            GHAssertEquals(@10, key, @"Expected key to be correct");
            GHAssertEquals(@"aap", value, @"Expected value to be correct");
        } else if (i == 1) {
            GHAssertEquals(@8, key, @"Expected key to be correct");
            GHAssertEquals(@"noot", value, @"Expected value to be correct");
        } else if (i == 2) {
            GHAssertEquals(@20, key, @"Expected key to be correct");
            GHAssertEquals(@"mies", value, @"Expected value to be correct");
        }
        i++;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    
    NSMutableDictionary *otherDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    GHAssertTrue(dict.count == otherDict.count, @"Expected counts to be equal");

    i = 0;
    for (id key in otherDict) {
        id value = [dict objectForKey:key];
        if (i == 0) {
            GHAssertEquals(@10, key, @"Expected key to be correct");
            GHAssertEquals(@"aap", value, @"Expected value to be correct");
        } else if (i == 1) {
            GHAssertEquals(@8, key, @"Expected key to be correct");
            GHAssertEquals(@"noot", value, @"Expected value to be correct");
        } else if (i == 2) {
            GHAssertEquals(@20, key, @"Expected key to be correct");
            GHAssertEquals(@"mies", value, @"Expected value to be correct");
        }
        i++;
    }
    
    [otherDict removeAllObjects];
    
    GHAssertTrue(otherDict.count == 0, @"Expected objects to be removed");
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
                GHAssertTrue([@"aap" isEqual:object], @"Expected objects to be equal");
            } else if (i == 1) {
                GHAssertTrue([@"noot" isEqual:object], @"Expected objects to be equal");
            } else if (i == 2) {
                GHAssertTrue([@"mies" isEqual:object], @"Expected objects to be equal");
            }
            i++;
        }
        
        //Should truncate file
        
        NSUInteger fileSize = [array fileSize];
        
        [array replaceObjectAtIndex:2 withObject:@"miep"];
        
        GHAssertTrue(fileSize == [array fileSize], @"Expected file size to remain the same");
        
        [array replaceObjectAtIndex:1 withObject:@"nootje"];
        
        [array removeObjectAtIndex:0];
        
        [array insertObject:@"aap" atIndex:0];
        
        [array insertObject:@"gorilla" atIndex:1];
        
        i = 0;
        for (id object in array) {
            if (i == 0) {
                GHAssertTrue([@"aap" isEqual:object], @"Expected objects to be equal");
            } else if (i == 1) {
                GHAssertTrue([@"gorilla" isEqual:object], @"Expected objects to be equal");
            } else if (i == 2) {
                GHAssertTrue([@"nootje" isEqual:object], @"Expected objects to be equal");
            } else if (i == 3) {
                GHAssertTrue([@"miep" isEqual:object], @"Expected objects to be equal");
            }
            i++;
        }
        
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        
        GHAssertNotNULL(data, @"Expected data to be serialized correctly");
        
        NSMutableArray *otherArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        GHAssertTrue(array.count == otherArray.count, @"Expected counts to be equal");
        
        i = 0;
        for (id object in array) {
            if (i == 0) {
                GHAssertTrue([@"aap" isEqual:object], @"Expected objects to be equal");
            } else if (i == 1) {
                GHAssertTrue([@"gorilla" isEqual:object], @"Expected objects to be equal");
            } else if (i == 2) {
                GHAssertTrue([@"nootje" isEqual:object], @"Expected objects to be equal");
            } else if (i == 3) {
                GHAssertTrue([@"miep" isEqual:object], @"Expected objects to be equal");
            }
            i++;
        }
        
        [otherArray removeAllObjects];
        
        GHAssertTrue(otherArray.count == 0, @"Expected objects to be removed");
        
        [array removeAllObjects];
        
        GHAssertTrue(array.count == 0, @"Expected count to be zero");
        
        GHAssertTrue([array fileSize] == 0, @"Expected filesize to be zero");

        [array release];
        array = nil;
        
    }
}

@end
