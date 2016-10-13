//
//  BMKeyedArchiveDataTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "BMKeyedArchiveDataTransformer.h"

@implementation BMKeyedArchiveDataTransformer

+ (Class)transformedValueClass {
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (id)transformedValue:(id)value {
    if ([value conformsToProtocol:@protocol(NSCoding)]) {
        return [NSKeyedArchiver archivedDataWithRootObject:value];
    } else {
        return nil;
    }
}

- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSData class]]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:value];
    } else {
        return nil;
    }
}

@end
