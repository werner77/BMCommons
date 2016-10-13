//
//  BMCodingHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "BMCodingHelper.h"

@implementation BMCodingHelper

static const BOOL kIgnoreFailures = YES;

+ (void)encodePropertiesFromDescriptors:(NSArray *)propertyDescriptors withCoder:(NSCoder *)coder forTarget:(id)target {
    for (BMPropertyDescriptor *pd in propertyDescriptors) {
        BMValueType valueType = pd.valueType;
        if (valueType == BMValueTypeObject) {
            id value = (target == nil) ? [pd callGetterWithIgnoreFailure:kIgnoreFailures] : [pd callGetterOnTarget:target ignoreFailure:kIgnoreFailures];
            [coder encodeObject:value forKey:pd.keyPath];
        } else {
            NSUInteger valueLength = 0;
            void *value = target == nil ? [pd invokeGetterWithIgnoreFailure:kIgnoreFailures valueLength:&valueLength] : [pd invokeGetterOnTarget:target ignoreFailure:kIgnoreFailures valueLength:&valueLength];
            if (value != nil && valueLength > 0) {
                [coder encodeBytes:value length:valueLength forKey:pd.keyPath];
            }
        }
    }
}

/**
 Decodes the properties specified by the propertyDescriptors (instances of BMPropertyDescriptor) using the specified coder using keyed coding.
 
 If target is nil, the target set in the property descriptors is used if any.
 */
+ (void)decodePropertiesFromDescriptors:(NSArray *)propertyDescriptors withCoder:(NSCoder *)coder forTarget:(id)target {
    for (BMPropertyDescriptor *pd in propertyDescriptors) {
        BMValueType valueType = pd.valueType;
        if (valueType == BMValueTypeObject) {
            id value = [coder decodeObjectForKey:pd.keyPath];
            if (target == nil) {
                [pd callSetter:value ignoreFailure:kIgnoreFailures];
            } else {
                [pd callSetterOnTarget:target withValue:value ignoreFailure:kIgnoreFailures];
            }
        } else {
            NSUInteger valueLength = 0;
            const uint8_t *bytes = [coder decodeBytesForKey:pd.keyPath returnedLength:&valueLength];
            
            if (target == nil) {
                [pd invokeSetter:(void *)bytes valueLength:valueLength ignoreFailure:kIgnoreFailures];
            } else {
                [pd invokeSetterOnTarget:target withValue:(void *)bytes valueLength:valueLength ignoreFailure:kIgnoreFailures];
            }
        }
    }
}

@end
