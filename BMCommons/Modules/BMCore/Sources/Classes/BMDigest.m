//
//  BMDigest.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/06/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <BMCommons/BMDigest.h>
#import <BMCommons/BMEncodingHelper.h>
#import <BMCommons/BMMD5Digest.h>
#import <BMCommons/BMSHA1Digest.h>
#import <BMCommons/BMSHA256Digest.h>
#import <BMCommons/BMPropertyDescriptor.h>

@implementation BMDigest {
    unsigned char *_result;
    BOOL _ready;
}

+ (instancetype)digestOfType:(BMDigestType)type {
    BMDigest *digest = nil;
    if (type == BMDigestTypeSHA1) {
        digest = [BMSHA1Digest new];
    } else if (type == BMDigestTypeMD5) {
        digest = [BMMD5Digest new];
    } else if (type == BMDigestTypeSHA256) {
        digest = [BMSHA256Digest new];
    }
    return digest;
}

- (id)init {
    if ((self = [super init])) {
        _result = malloc([self lengthForDigest]);
        [self initDigest];
    }
    return self;
}

- (void)dealloc {
    if (_result) free(_result);
}

- (NSUInteger)lengthForDigest {
    return 0;
}

- (void)updateWithData:(NSData *)data last:(BOOL)last {
    [self updateWithBytes:(data == nil ? nil : [data bytes]) length:(data == nil ? 0 : [data length]) last:last];
}

- (void)updateWithBytes:(const void *)bytes length:(NSUInteger)length last:(BOOL)last {
    if (!_ready) {
        if (bytes != nil && length > 0) {
            [self updateDigestWithBytes:bytes length:length];
        }
        if (last) {
            [self finalizeDigest];
        }
    }
}

- (void)finalizeDigest {
    if (!_ready) {
        [self finalizeDigestWithResult:_result];
        _ready = YES;
    }
}

- (void)updateWithProperties:(NSArray *)propertyDescriptors fromObject:(id)object {
    for (BMPropertyDescriptor *pd in propertyDescriptors) {
        @autoreleasepool {
            id value1 = [pd callGetterOnTarget:object ignoreFailure:YES];
            
            id<NSCoding> codingValue = nil;
            if ([value1 conformsToProtocol:@protocol(NSCoding)]) {
                codingValue = value1;
            } else {
                codingValue = [NSNumber numberWithUnsignedInteger:[value1 hash]];
            }
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:codingValue];
            [self updateWithData:data last:NO];
        }
    }
}

- (void)updateWithValueForKeyPaths:(NSArray *)keyPaths fromObject:(id)object {
    NSMutableArray *propertyDescriptors = [NSMutableArray array];
    for (NSString *keyPath in keyPaths) {
        BMPropertyDescriptor *pd = [BMPropertyDescriptor propertyDescriptorFromKeyPath:keyPath];
        [propertyDescriptors addObject:pd];
    }
    [self updateWithProperties:propertyDescriptors fromObject:object];
}

- (NSData *)dataRepresentation {
    if (_ready) {
        return [NSData dataWithBytes:_result length:[self lengthForDigest]];
    } else {
        return nil;
    }
}

- (NSString *)stringRepresentation {
    NSData *digestData = [self dataRepresentation];
    return digestData ? [BMEncodingHelper hexEncodedStringForData:digestData] : nil;
}

@end
