//
//  BMSettingsPropertyDescriptor.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMSettingsPropertyDescriptor.h>

@implementation BMSettingsPropertyDescriptor

/**
 Constructs a property descriptor for an object type property with the specified keypath and default value.
 */
+ (BMSettingsPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath defaultValue:(id)defaultValue {
    return [self propertyDescriptorFromKeyPath:theKeyPath valueType:BMValueTypeObject defaultValue:defaultValue];
}

/**
 Constructs a property descriptor for an object type property with the specified keypath and default value and custom keyName to use for storage in NSUserDefaults.
 */
+ (BMSettingsPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath defaultValue:(id)defaultValue keyName:(NSString *)keyName {
    return [self propertyDescriptorFromKeyPath:theKeyPath valueType:BMValueTypeObject defaultValue:defaultValue keyName:keyName];
}

+ (BMSettingsPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath valueType:(BMValueType)valueType defaultValue:(id)defaultValue {
    BMSettingsPropertyDescriptor *pd = (BMSettingsPropertyDescriptor *)[self propertyDescriptorFromKeyPath:theKeyPath valueType:valueType];
    pd.defaultValue = defaultValue;
    return pd;
}

+ (BMSettingsPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath valueType:(BMValueType)valueType defaultValue:(id)defaultValue keyName:(NSString *)keyName {
    BMSettingsPropertyDescriptor *pd = (BMSettingsPropertyDescriptor *)[self propertyDescriptorFromKeyPath:theKeyPath valueType:valueType];
    pd.defaultValue = defaultValue;
    pd.keyName = keyName;
    return pd;
}

@end
