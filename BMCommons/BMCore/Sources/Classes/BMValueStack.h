//
// Created by Werner Altewischer on 10/10/16.
// Copyright (c) 2016 BehindMedia. All rights reserved.
//

#import <BMCore/BMCoreObject.h>
#import <BMCore/BMCore.h>
#import <BMCore/BMPropertyDescriptor.h>

@class BMValueStack;

@protocol BMValueStackListener<NSObject>

/**
 * Called when the value of the stack changes.
 *
 * @param stack The stack
 */
- (void)valueStackDidChangeValue:(BMValueStack *)stack;

@end

typedef id (^BMValueComputationBlock)(NSArray *values);

/**
 Class to implement a cumulative value based on a push/pop mechanism.

 This class is thread safe.
 */
@interface BMValueStack<__covariant T> : BMCoreObject

BM_LISTENER_METHODS_DECLARATION(BMValueStackListener)

/**
 If set to YES, values that were pushed for owners that were deallocated will automatically be popped.

 Default is NO which enforces responsibility of owners to pop the values they pushed themselves.
 */
@property (assign) BOOL shouldAutomaticallyCleanupStatesForDeallocatedOwners;

/**
 * The default value if no values are present on the stack, defaults to nil.
 */
@property (strong) T defaultValue;

/**
 * The block to use to computate the resulting value from the stack values. If nil, the topmost value is returned.
 * If no value is present on the stack, the defaultValue is returned.
 */
@property (copy) BMValueComputationBlock resultingValueComputationBlock;

/**
 Optional property descriptor to synchronize the value with.

 This property is set every time the value property changes.
 */
@property (strong) BMPropertyDescriptor *propertyDescriptor;

/**
 Pushes the specified value for the specified owner.
 */
- (void)pushValue:(T)value forOwner:(id)owner;

/**
 Pops the top most value for the specified owner, returns the same value as [[self popValuesForOwner:] firstObject].
 */
- (T)popValueForOwner:(id)owner;

/**
 * Pops all the values for the specified owner.
 *
 * The returned values are in reverse order of push, newest first, oldest last.
 */
- (NSArray<T> *)popValuesForOwner:(id)owner;

/**
 * Returns all the values for the specified owner in reverse order of push, newest first, oldest last.
 */
- (NSArray<T> *)valuesForOwner:(id)owner;

/**
 The resulting value based on the full stack and resultingValueFromStackValues implementation.
 */
- (T)value;

/**
 Removes all stacked values.
 */
- (void)reset;

@end

@interface BMValueStack<__covariant T>(Protected)

/**
 * By default uses the resultingValueComputationBlock to compute the resulting values from the array of stack values.
 * If resultingValueComputationBlock == nil by default the top-most value is returned.
 */
- (T)resultingValueFromStackValues:(NSArray<T> *)stackValue;

/**
 * Override hook to perform after the value changed.
 */
- (void)valueDidChange;

/**
 * Call to update/recompute the internal value
 */
- (void)updateValue;

@end
