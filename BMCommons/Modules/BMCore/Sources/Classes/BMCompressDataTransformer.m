//
//  BMCompressDataTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 08/10/15.
//  Copyright © 2015 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCompressDataTransformer.h>
#import "NSData+BMCompression.h"

@implementation BMCompressDataTransformer

+ (Class)transformedValueClass {
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)init {
    if ((self = [super init])) {
        self.compressionType = BMCompressionTypeZLIB;
    }
    return self;
}

- (id)transformedValue:(id)value {
    NSData *data = value;
    if (self.compressionType == BMCompressionTypeZLIB) {
        data = [data bmZlibDeflate];
    } else if (self.compressionType == BMCompressionTypeGZIP) {
        data = [data bmGzipDeflate];
    }
    return data;
}

- (id)reverseTransformedValue:(id)value {
    NSData *data = value;    
    if (self.compressionType == BMCompressionTypeZLIB) {
        data = [data bmZlibInflate];
    } else if (self.compressionType == BMCompressionTypeGZIP) {
        data = [data bmGzipInflate];
    }
    return data;
}

@end