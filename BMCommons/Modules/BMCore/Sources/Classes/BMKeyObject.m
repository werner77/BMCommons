//
//  BMKeyObject.m
//  BMCommons
//
//  Created by Werner Altewischer on 02/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMKeyObject.h>
#import <BMCommons/BMPropertyDescriptor.h>

@implementation BMKeyObject

static NSMutableDictionary *propertyDescriptorsDict = nil;

+ (NSArray *)keyProperties {
    return nil;
}

+ (NSArray *)propertyDescriptors {
    @synchronized([BMKeyObject class]) {
        if (propertyDescriptorsDict == nil) {
            propertyDescriptorsDict = [NSMutableDictionary new];
        }
        id key = self;
        NSMutableArray *propertyDescriptors = [propertyDescriptorsDict objectForKey:key];
        if (propertyDescriptors == nil) {
            propertyDescriptors = [NSMutableArray array];
            for (NSString *property in [self keyProperties]) {
                BMPropertyDescriptor *pd = [BMPropertyDescriptor propertyDescriptorFromKeyPath:property withTarget:nil];
                [(NSMutableArray *)propertyDescriptors addObject:pd];
            }
            [propertyDescriptorsDict setObject:propertyDescriptors forKey:key];
        }
        return propertyDescriptors;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    id copy = [[[self class] allocWithZone:zone] init];
    NSArray *propertyDescriptors = [[self class] propertyDescriptors];
    for (BMPropertyDescriptor *pd in propertyDescriptors) {
        id <NSObject> value = [pd callGetterOnTarget:self];
        [pd callSetterOnTarget:copy withValue:value];
    }
    return copy;
}

- (NSUInteger)hash {
    NSUInteger hash = NSStringFromClass([self class]).hash;
    NSArray *propertyDescriptors = [[self class] propertyDescriptors];
    for (BMPropertyDescriptor *pd in propertyDescriptors) {
        id <NSObject> value = [pd callGetterOnTarget:self];
        hash = 31 * hash + value.hash;
    }
    return hash;
}

- (BOOL)isEqual:(id)object {
    BOOL equal = YES;
    if (self != object) {
        if ([object class] == [self class]) {
            NSArray *propertyDescriptors = [[self class] propertyDescriptors];
            for (BMPropertyDescriptor *pd in propertyDescriptors) {
                id <NSObject> value = [pd callGetterOnTarget:self];
                id <NSObject> otherValue = [pd callGetterOnTarget:object];
                equal = equal && (value == otherValue || [value isEqual:otherValue]);
            }
        } else {
            equal = NO;
        }
    }
    return equal;
}

@end
