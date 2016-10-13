//
//  BMBooleanStack.h
//  BMCommons
//
//  Created by Werner Altewischer on 05/11/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCore/BMCore.h>
#import <BMCore/BMPropertyDescriptor.h>
#import "BMValueStack.h"

typedef NS_ENUM(NSUInteger, BMBooleanStackOperationType) {
    BMBooleanStackOperationTypeTop = 0, //Top value of the stack determines the outcome
    BMBooleanStackOperationTypeOR = 1, //OR of all booleans in the stack determines the outcome
    BMBooleanStackOperationTypeAND = 2 //AND of all booleans in the stack determines the outcome
};

/**
 Class to implement a boolean state based on a push/pop mechanism.
 
 This can be used to update a boolean state which is influenced by multiple callers, with no single owner having the knowledge or responsibility to determine the total outcome of the boolean state. The resulting boolean state is determined by the stackOperationType.
 
 This could be used for example to set the idleTimerDisabled state of UIApplication in an iOS application.
 
 This class is thread safe.
 */
@interface BMBooleanStack : BMValueStack<NSNumber *>

/**
 The operation type of the stack, determining the outcome of the boolean state.
 
 BMBooleanStackOperationTypeTop (default): top boolean in the stack determines the state
 BMBooleanStackOperationTypeOR: OR of all booleans in the stack determines the state.
 BMBooleanStackOperationTypeAND: AND of all booleans in the stack determines the state.
 
 @see state
 */
@property (assign) BMBooleanStackOperationType operationType;

/**
 Optional property descriptor to synchronize the boolean state with.
 
 This property is set every time the state property changes.
 */
@property (strong) BMPropertyDescriptor *booleanPropertyDescriptor;

/**
 The default state if the stack is empty.
 */
@property (assign) BOOL defaultState;

/**
 Pushes the specified boolean state for the specified owner.
 */
- (void)pushState:(BOOL)state forOwner:(id)owner;

/**
 Pops the top most state for the specified owner.
 */
- (void)popStateForOwner:(id)owner;

/**
 * Pops all the states for the specified owner.
 */
- (void)popStatesForOwner:(id)owner;

/**
 The resulting state of the boolean property based on the full stack and operationType.
 */
- (BOOL)state;

@end
