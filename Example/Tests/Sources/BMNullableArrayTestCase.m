//
// Created by Werner Altewischer on 13/05/2017.
// Copyright (c) 2017 Werner Altewischer. All rights reserved.
//

#import <BMCommons/BMURLCache.h>
#import <BMCommons/BMNullableArray.h>
#import "BMNullableArrayTestCase.h"

@interface BMNullableArrayTestCase()

@property (nonatomic, strong) BMNullableArray* array;
@property (nonatomic, strong) BMURLCache *urlCache;

@end

@implementation BMNullableArrayTestCase {

}

- (void)setUp {
    [super setUp];
    self.array = [[BMNullableArray alloc] initWithObjects:(id []){nil, @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20"} count:21];
}

- (void)testFastEnumeration {
    NSUInteger i = 0;
    for (id obj in self.array) {
        if (i == 0) {
            XCTAssertNil(obj);
        } else {
            NSString *value = [NSString stringWithFormat:@"%tu", i];
            XCTAssertEqualObjects(value, obj);
        }
        i++;
    }
}

- (void)testMutationException {
    NSUInteger i = 0;
    @try {
        for (id obj in self.array) {
            if (i == 0) {
                XCTAssertNil(obj);
            } else {
                [self.array compact];
            }
            NSLog(@"objectAtIndex:%tu=%@", i, obj);
            i++;
        }
        XCTFail(@"Expected exception to be thrown");
    } @catch(NSException *ex) {
        NSLog(@"Caught exception %@", ex);
    }

    @try {
        for (id obj in self.array) {
            if (i == 0) {
                XCTAssertNil(obj);
            } else {
                [self.array replaceObjectAtIndex:10 withObject:@"aap"];
            }
            NSLog(@"objectAtIndex:%tu=%@", i, obj);
            i++;
        }
        XCTFail(@"Expected exception to be thrown");
    } @catch(NSException *ex) {
        NSLog(@"Caught exception %@", ex);
    }
}

- (void)testWeakArray {
    NSObject *obj1, *obj3;
    @autoreleasepool {
        NSObject *object1 = [NSObject new];
        NSObject *object2 = [NSObject new];
        NSObject *object3 = [NSObject new];

        self.array = [[BMNullableArray alloc] initWithArray:@[object1, object2, object3]];
        self.array.retainsObjects = NO;

        XCTAssertEqualObjects(object2, [self.array objectAtIndex:1]);

        obj1 = object1;
        obj3 = object3;

        //Object 2 should be released
    }

    //Check whether the array reflects this

    XCTAssertEqualObjects(obj1, [self.array objectAtIndex:0]);

    XCTAssertNil([self.array objectAtIndex:1]);

    XCTAssertEqualObjects(obj3, [self.array objectAtIndex:2]);

}

- (void)testStrongArray {

    NSObject *obj1, *obj3;
    @autoreleasepool {
        NSObject *object1 = [NSObject new];
        NSObject *object2 = [NSObject new];
        NSObject *object3 = [NSObject new];

        self.array = [[BMNullableArray alloc] initWithArray:@[object1, object2, object3]];
        self.array.retainsObjects = YES;

        XCTAssertEqualObjects(object2, [self.array objectAtIndex:1]);

        obj1 = object1;
        obj3 = object3;

        //Object 2 should be released
    }

    //Check whether the array reflects this

    XCTAssertEqualObjects(obj1, [self.array objectAtIndex:0]);

    XCTAssertNotNil([self.array objectAtIndex:1]);

    XCTAssertEqualObjects(obj3, [self.array objectAtIndex:2]);
}

- (void)testCompact {
    XCTAssertEqual(21, self.array.count);
    XCTAssertNil([self.array objectAtIndex:0]);
    [self.array compact];
    XCTAssertEqual(20, self.array.count);
    XCTAssertNotNil([self.array objectAtIndex:0]);
}

- (void)testAllObjects {
    XCTAssertEqual(21, self.array.count);
    XCTAssertNil([self.array objectAtIndex:0]);
    NSArray *allObjects = [self.array allObjects];
    XCTAssertEqual(20, allObjects.count);
    XCTAssertNotNil(allObjects[0]);
}

- (void)testAddObject {
    XCTAssertEqual(21, self.array.count);
    [self.array addObject:nil];
    XCTAssertEqual(22, self.array.count);
    XCTAssertNil([self.array objectAtIndex:21]);
    NSString *string = @"Bla";
    [self.array addObject:string];
    XCTAssertEqual(string, [self.array objectAtIndex:22]);
}

- (void)testObjectAtIndex {
    XCTAssertNil([self.array objectAtIndex:0]);
    XCTAssertEqualObjects(@"1", [self.array objectAtIndex:1]);

    @try {
        [self.array objectAtIndex:40];
        XCTFail(@"Expected exception to be thrown");
    } @catch (NSException *exception1) {
        //OK
    }
}

- (void)testRemoveObjectAtIndex {
    XCTAssertEqual(21, self.array.count);
    XCTAssertNil([self.array objectAtIndex:0]);
    [self.array removeObjectAtIndex:0];
    XCTAssertEqual(20, self.array.count);
    XCTAssertNotNil([self.array objectAtIndex:0]);

    @try {
        [self.array removeObjectAtIndex:40];
        XCTFail(@"Expected exception to be thrown");
    } @catch (NSException *exception1) {
        //OK
    }
}

- (void)testObjectIdenticalTo {
    NSString *string = [self.array objectAtIndex:13];

    XCTAssertTrue([self.array containsObjectIdenticalTo:string]);
    XCTAssertEqual(13, [self.array indexOfObjectIdenticalTo:string]);

    NSString *stringCopy = [NSMutableString stringWithString:string];

    XCTAssertEqualObjects(string, stringCopy);

    XCTAssertFalse([self.array containsObjectIdenticalTo:stringCopy]);
    XCTAssertEqual(NSNotFound, [self.array indexOfObjectIdenticalTo:stringCopy]);

    //Should have no effect
    [self.array removeObjectIdenticalTo:stringCopy];

    XCTAssertEqual(21, [self.array count]);

    [self.array removeObjectIdenticalTo:string];

    XCTAssertEqual(20, [self.array count]);

    XCTAssertNotEqual(string, [self.array objectAtIndex:13]);

}

- (void)testObjectEqualTo {
    NSString *string = [self.array objectAtIndex:13];

    NSString *stringCopy = [NSMutableString stringWithString:string];

    XCTAssertEqualObjects(string, stringCopy);

    XCTAssertTrue([self.array containsObject:stringCopy]);
    XCTAssertEqual(13, [self.array indexOfObject:stringCopy]);

    XCTAssertEqual(21, [self.array count]);

    [self.array removeObject:stringCopy];

    XCTAssertEqual(20, [self.array count]);

    XCTAssertNotEqualObjects(string, [self.array objectAtIndex:13]);

}

- (void)testInsertObject {

    NSString *string = @"Bla";

    NSString *currentObj1 = [self.array objectAtIndex:9];
    NSString *currentObj2 = [self.array objectAtIndex:10];

    XCTAssertEqual(21, [self.array count]);

    [self.array insertObject:string atIndex:10];

    XCTAssertEqual(currentObj1, [self.array objectAtIndex:9]);
    XCTAssertEqual(string, [self.array objectAtIndex:10]);
    XCTAssertEqual(currentObj2, [self.array objectAtIndex:11]);
    XCTAssertEqual(22, [self.array count]);

    @try {
        [self.array insertObject:string atIndex:40];
        XCTFail(@"Expected exception to be thrown");
    } @catch (NSException *exception1) {
        //OK
    }
}

- (void)testReplaceObject {
    NSString *string = @"Bla";

    NSString *currentObj1 = [self.array objectAtIndex:9];
    NSString *currentObj2 = [self.array objectAtIndex:10];

    XCTAssertEqual(21, [self.array count]);

    [self.array replaceObjectAtIndex:10 withObject:string];

    XCTAssertEqual(currentObj1, [self.array objectAtIndex:9]);
    XCTAssertEqual(string, [self.array objectAtIndex:10]);
    XCTAssertNotEqual(currentObj2, [self.array objectAtIndex:11]);
    XCTAssertEqual(21, [self.array count]);

    @try {
        [self.array replaceObjectAtIndex:40 withObject:string];
        XCTFail(@"Expected exception to be thrown");
    } @catch (NSException *exception1) {
        //OK
    }
}

@end
