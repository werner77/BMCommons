//
//  BMBooleanStackTestCase.m
//  BMCommons
//
//  Created by Werner Altewischer on 05/11/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "BMBooleanStackTestCase.h"
#import <BMCommons/BMBooleanStack.h>

@implementation BMBooleanStackTestCase

- (void)testBooleanStack {
    
    NSObject *owner1 = [NSObject new];
    NSObject *owner2 = [NSObject new];
    
    BMBooleanStack *booleanStack = [BMBooleanStack new];
    
    booleanStack.operationType = BMBooleanStackOperationTypeTop;
    booleanStack.defaultState = YES;
    booleanStack.booleanPropertyDescriptor = [BMPropertyDescriptor propertyDescriptorFromKeyPath:@"state" withTarget:self valueType:BMValueTypeBoolean];
    booleanStack.shouldAutomaticallyCleanupStatesForDeallocatedOwners = YES;
    
    XCTAssertTrue(booleanStack.state, @"Expected state to be true");
    XCTAssertTrue(self.state, @"Expected state to be true");
    
    [booleanStack pushState:NO forOwner:owner1];
    
    XCTAssertFalse(booleanStack.state, @"Expected state to be false");
    XCTAssertFalse(self.state, @"Expected state to be false");
    
    [booleanStack pushState:YES forOwner:owner2];
    
    XCTAssertTrue(booleanStack.state, @"Expected state to be true");
    XCTAssertTrue(self.state, @"Expected state to be true");
    
    booleanStack.operationType = BMBooleanStackOperationTypeAND;
    
    XCTAssertFalse(booleanStack.state, @"Expected state to be false");
    XCTAssertFalse(self.state, @"Expected state to be false");
    
    booleanStack.operationType = BMBooleanStackOperationTypeOR;
    
    XCTAssertTrue(booleanStack.state, @"Expected state to be true");
    
    booleanStack.operationType = BMBooleanStackOperationTypeAND;
    
    XCTAssertFalse(booleanStack.state, @"Expected state to be false");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue(booleanStack.state, @"Expected state to be true");
        XCTAssertTrue(self.state, @"Expected state to be true");
    });
}

@end
