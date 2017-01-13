//
//  BMTestCodeableObject.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "BMTestCodeableObject.h"
#import <BMCommons/BMCodingHelper.h>

@implementation BMTestCodeableObject

+ (NSArray *)propertyDescriptorsForCoding {
    return @[
             [BMPropertyDescriptor propertyDescriptorFromKeyPath:@"dateProperty" valueType:BMValueTypeObject],
             [BMPropertyDescriptor propertyDescriptorFromKeyPath:@"numberProperty" valueType:BMValueTypeObject],
             [BMPropertyDescriptor propertyDescriptorFromKeyPath:@"stringProperty" valueType:BMValueTypeObject],
             [BMPropertyDescriptor propertyDescriptorFromKeyPath:@"intProperty" valueType:BMValueTypeInteger],
             [BMPropertyDescriptor propertyDescriptorFromKeyPath:@"boolProperty" valueType:BMValueTypeBoolean],
             [BMPropertyDescriptor propertyDescriptorFromKeyPath:@"doubleProperty" valueType:BMValueTypeDouble],
             [BMPropertyDescriptor propertyDescriptorFromKeyPath:@"floatProperty" valueType:BMValueTypeFloat],
             ];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [self init])) {
        [BMCodingHelper decodePropertiesFromDescriptors:[[self class] propertyDescriptorsForCoding] withCoder:coder forTarget:self];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [BMCodingHelper encodePropertiesFromDescriptors:[[self class] propertyDescriptorsForCoding] withCoder:coder forTarget:self];
}

@end
