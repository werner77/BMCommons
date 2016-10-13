//
// Created by Werner Altewischer on 12/10/16.
// Copyright (c) 2016 BehindMedia. All rights reserved.
//

#import "NSMethodSignature+BMCommons.h"
#import <BMCore/BMCore.h>

@implementation NSMethodSignature (BMCommons)

static const NSUInteger kHiddenArgumentCount = 2;

- (NSUInteger)bmNumberOfSelectorArguments {
    NSUInteger ret = 0;
    NSUInteger numberOfArguments = self.numberOfArguments;
    if (numberOfArguments > kHiddenArgumentCount) {
        ret = numberOfArguments - kHiddenArgumentCount;
    }
    return ret;
}

- (NSUInteger)bmSelectorArgumentIndexForArgumentIndex:(NSUInteger)argumentIndex {
    NSUInteger ret = 0;
    if (argumentIndex < self.numberOfArguments && argumentIndex >= kHiddenArgumentCount) {
        ret = argumentIndex - kHiddenArgumentCount;
    } else {
        BMThrowIllegalArgumentException([NSString stringWithFormat:@"Illegal argumentIndex supplied: %zd. Should be >= %tu and < %tu", argumentIndex, kHiddenArgumentCount, self.numberOfArguments]);
    }
    return ret;
}

- (NSUInteger)bmArgumentIndexForSelectorArgumentIndex:(NSUInteger)argumentIndex {
    NSUInteger ret = 0;
    if (argumentIndex < self.bmNumberOfSelectorArguments) {
        ret = argumentIndex + kHiddenArgumentCount;
    } else {
        BMThrowIllegalArgumentException([NSString stringWithFormat:@"Illegal selectorArgumentIndex supplied: %zd. Should be < %tu", argumentIndex, self.bmNumberOfSelectorArguments]);
    }
    return ret;
}

- (NSUInteger)bmArgumentLengthAtIndex:(NSUInteger)argumentIndex {
    NSUInteger argSize = 0;
    NSUInteger alignedArgSize = 0;

    //Checks argumentIndex validity, will throw exception if not valid
    [self bmSelectorArgumentIndexForArgumentIndex:argumentIndex];

    const char * argType = [self getArgumentTypeAtIndex:argumentIndex];

    if (argType != NULL) {
        NSGetSizeAndAlignment ( argType, &argSize, &alignedArgSize );
    }
    return argSize;
}

@end