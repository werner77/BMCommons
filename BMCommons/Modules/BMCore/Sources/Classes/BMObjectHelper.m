//
//  BMObjectHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 31/08/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMObjectHelper.h>
#import <BMCommons/BMPropertyDescriptor.h>

#import <BMCommons/BMCore.h>

@implementation BMObjectHelper

+ (id)filterNSNullObject:(id)object {
    if ([NSNull null] == object) {
        return nil;
    } else {
        return object;
    }
}

+ (id)filterNullObject:(id)object {
    if (object == nil) {
        return [NSNull null];
    } else {
        return object;
    }
}

+ (id)filterNullObject:(id)object withDefaultValue:(id)defaultValue {
    if (object == nil) {
        return defaultValue;
    } else {
        return object;
    }
}

+ (void)setObject:(id)object forKey:(id)key inDictionary:(NSMutableDictionary *)dict {
    if (object && key) {
        [dict setObject:object forKey:key];
    }
}

+ (BOOL)validateObject:(id)object attributes:(NSArray *)attributes withError:(NSError **)error {
    for (NSString *key in attributes) {
        id value = [object valueForKey:key];
        if (![object validateValue:&value forKey:key error:error]) {
            return NO;
        }
    }
    return YES;
}

+ (BOOL)isObject:(id)object1 equalToObject:(id)object2 forKeyPaths:(NSArray *)keyPaths {
    NSArray *propertyDescriptors = [self descriptorsForKeyPaths:keyPaths];
    return [self isObject:object1 equalToObject:object2 forPropertyDescriptors:propertyDescriptors];
}

+ (BOOL)isObject:(id)object1 equalToObject:(id)object2 forPropertyDescriptors:(NSArray *)propertyDescriptors {
    BOOL equal = YES;
    if (object1 != object2) {
        for (BMPropertyDescriptor *pd in propertyDescriptors) {
            id value1 = [pd callGetterOnTarget:object1 ignoreFailure:YES];
            id value2 = [pd callGetterOnTarget:object2 ignoreFailure:YES];
            equal = (value1 == value2 || [value1 isEqual:value2]);
            if (!equal) {
                break;
            }
        }
    }
    return equal;
}

+ (NSUInteger)hashCodeForObject:(id)object withKeyPaths:(NSArray *)keyPaths {
    NSArray *propertyDescriptors = [self descriptorsForKeyPaths:keyPaths];
    return [self hashCodeForObject:object withPropertyDescriptors:propertyDescriptors];
}

+ (NSUInteger)hashCodeForObject:(id)object withPropertyDescriptors:(NSArray *)propertyDescriptors {
    NSUInteger hashCode = 0;
    for (BMPropertyDescriptor *pd in propertyDescriptors) {
        id value1 = [pd callGetterOnTarget:object ignoreFailure:YES];
        BM_APPEND_HASH_ORDERED(hashCode, [value1 hash]);
    }
    return hashCode;
}

+ (NSArray *)descriptorsForKeyPaths:(NSArray *)keyPaths {
    NSMutableArray *propertyDescriptors = [NSMutableArray array];
    for (NSString *keyPath in keyPaths) {
        BMPropertyDescriptor *pd = [BMPropertyDescriptor propertyDescriptorFromKeyPath:keyPath];
        [propertyDescriptors addObject:pd];
    }
    return propertyDescriptors;
}

+ (NSString *)digestOfType:(BMDigestType)digestType forObject:(id)object withPropertyDescriptors:(NSArray *)propertyDescriptors {
    BMDigest *digest = [BMDigest digestOfType:digestType];
    if (propertyDescriptors && object) {
        [digest updateWithProperties:propertyDescriptors fromObject:object];
    }
    [digest updateWithData:nil last:YES];
    return [digest stringRepresentation];
}

+ (NSString *)digestOfType:(BMDigestType)digestType forObject:(id)object withKeyPaths:(NSArray *)keyPaths {
    NSArray *propertyDescriptors = [self descriptorsForKeyPaths:keyPaths];
    return [self digestOfType:digestType forObject:object withPropertyDescriptors:propertyDescriptors];
}

@end
