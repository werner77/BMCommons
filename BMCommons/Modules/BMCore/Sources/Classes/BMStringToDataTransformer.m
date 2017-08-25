//
//  BMStringToDataTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/31/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMStringToDataTransformer.h>

@implementation BMStringToDataTransformer

+ (Class)transformedValueClass {
	return [NSData class];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

- (id)init {
    if ((self = [super init])) {
        self.encoding = NSUTF8StringEncoding;
    }
    return self;
}

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        NSString *s = value;
        return [s dataUsingEncoding:self.encoding];
    } else {
        return nil;
    }
}

- (id)reverseTransformedValue:(id)value {
	if ([value isKindOfClass:[NSData class]]) {
        NSData *data = value;
        return [[NSString alloc] initWithData:data encoding:self.encoding];
    } else {
        return nil;
    }
}

@end
