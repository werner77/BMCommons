//
//  NSInvocation+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/01/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (BMCommons)

/**
 * Constructs an NSInvocation for the specified target, selector and method arguments.
 *
 * @param target The target
 * @param selector The selector
 * @param args Arguments
 * @param argCount Number of arguments
 * @return The invocation
 */
+ (NSInvocation *)bmInvocationWithTarget:(id)target selector:(SEL)selector args:(void **)args argCount:(NSUInteger)argCount;

/**
 * Return the argument by shifting the argument index + 2 (skipping hidden target and selector arguments).
 *
 * This method is safe in the sense that it checks if the length of the supplied buffer is equal to the length of the argument at the specified index and that the index < methodSignature.bmNumberOfSelectorArguments.
 * Will throw a BMIllegalArgumentException otherwise.
 */
- (void)bmSafelyGetSelectorArgument:(void *)argumentLocation withLength:(NSUInteger)argumentLength atIndex:(NSUInteger)idx;

/**
 * Sets the method argument by shifting the argument index + 2 (skipping hidden target and selector arguments).
 *
 * This method is safe in the sense that it checks if the length of the supplied buffer is equal to the length of the argument at the specified index and that the index < methodSignature.bmNumberOfSelectorArguments.
 * Will throw a BMIllegalArgumentException otherwise.
 */
- (void)bmSafelySetMethodArgument:(void *)argumentLocation withLength:(NSUInteger)argumentLength atIndex:(NSUInteger)idx;

/**
 * Invokes the invocation and returns the return value to the supplied buffer.
 * Will throw a BMIllegalArgumentException if retLength does not match the return value length for the method corresponding to this invocation.
 *
 */
- (void)bmSafelyInvokeAndReturnValue:(void *)retLoc withLength:(NSUInteger)retLength;

/**
 * Invokes the invocation on the specified target and returns the return value to the supplied buffer.
 * Will throw a BMIllegalArgumentException if retLength does not match the return value length for the method corresponding to this invocation.
 *
 */
- (void)bmSafelyInvokeAndReturnValue:(void *)retLoc withLength:(NSUInteger)retLength target:(id)target;

@end
