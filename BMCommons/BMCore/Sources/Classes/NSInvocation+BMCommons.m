//
//  NSInvocation+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/01/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "NSInvocation+BMCommons.h"
#import "NSMethodSignature+BMCommons.h"
#import <BMCore/BMCore.h>

@implementation NSInvocation (BMCommons)

+ (NSInvocation *)bmInvocationWithTarget:(id)target selector:(SEL)selector args:(void **)args argCount:(NSUInteger)argCount {
    NSInvocation* invo = nil;
    NSMethodSignature *sig = [target methodSignatureForSelector:selector];
    if (sig) {
        argCount = MIN(argCount, sig.numberOfArguments - 2);
        invo = [NSInvocation invocationWithMethodSignature:sig];
        [invo setTarget:target];
        [invo setSelector:selector];
        
        if (args != nil) {
            for (NSUInteger i = 0; i < argCount; ++i) {
                void *arg = args[i];
                [invo setArgument:arg atIndex:(i + 2)];
            }
        }
    }
    return invo;
}

- (NSUInteger)bmValidateSelectorArgumentAtIndex:(NSUInteger)idx withLength:(NSUInteger)argumentLength {
    NSUInteger argumentIndex = [self.methodSignature bmArgumentIndexForSelectorArgumentIndex:idx];
    NSUInteger expectedArgumentLength = [self.methodSignature bmArgumentLengthAtIndex:argumentIndex];

    if (expectedArgumentLength != argumentLength) {
        BMThrowIllegalArgumentException([NSString stringWithFormat:@"Argument length %tu is not equal to the expected length %tu for selector argument at index %tu", argumentLength, expectedArgumentLength, idx]);
    }
    return argumentIndex;
}

- (void)bmValidateReturnLength:(NSUInteger)returnLength {
    NSUInteger expectedReturnLength = self.methodSignature.methodReturnLength;
    if (expectedReturnLength != returnLength) {
        BMThrowIllegalArgumentException([NSString stringWithFormat:@"Method return length %tu is not equal to the expected length %tu", returnLength, expectedReturnLength]);
    }
}

- (void)bmSafelyGetSelectorArgument:(void *)argumentLocation withLength:(NSUInteger)argumentLength atIndex:(NSUInteger)idx {
    NSUInteger argumentIndex = [self bmValidateSelectorArgumentAtIndex:idx withLength:argumentLength];
    [self getArgument:argumentLocation atIndex:argumentIndex];
}


- (void)bmSafelySetMethodArgument:(void *)argumentLocation withLength:(NSUInteger)argumentLength atIndex:(NSUInteger)idx {
    NSUInteger argumentIndex = [self bmValidateSelectorArgumentAtIndex:idx withLength:argumentLength];
    [self setArgument:argumentLocation atIndex:argumentIndex];
}

- (void)bmSafelyInvokeAndReturnValue:(void *)retLoc withLength:(NSUInteger)retLength {
    [self bmValidateReturnLength:retLength];
    [self invoke];
    [self getReturnValue:retLoc];
}

- (void)bmSafelyInvokeAndReturnValue:(void *)retLoc withLength:(NSUInteger)retLength target:(id)target {
    [self bmValidateReturnLength:retLength];
    [self invokeWithTarget:target];
    [self getReturnValue:retLoc];
}

@end
