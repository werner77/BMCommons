//
//  BMBase64DataTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 06/08/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "BMBase64DataTransformer.h"
#import "BMEncodingHelper.h"

@implementation BMBase64DataTransformer

+ (Class)transformedValueClass {
    return [NSString class];
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
    NSData *data = value;
    return [BMEncodingHelper base64EncodedStringForData:data withLineLength:0 urlFriendly:self.urlFriendlyMode];
}

- (id)reverseTransformedValue:(id)value {
    NSString *s = value;
    return [BMEncodingHelper dataWithBase64EncodedString:s urlFriendly:self.urlFriendlyMode];
}

@end
