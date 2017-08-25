//
//  BMSettingsPropertyDescriptor.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMPropertyDescriptor.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Extension of BMPropertyDescriptor for describing properties used by BMAbstractSettingsObject.
 
 @see BMAbstractSettingsObject
 */
@interface BMSettingsPropertyDescriptor : BMPropertyDescriptor

/**
 Default value for the property.
 */
@property (nullable, nonatomic, strong) id defaultValue;

/**
 The key name of the property to use for storing in NSUserDefaults.
 
 If nil a default keyName is used.
 */
@property (nullable, nonatomic, strong) NSString *keyName;

/**
 Constructs a property descriptor for an object type property with the specified keypath and default value.
 */
+ (BMSettingsPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath defaultValue:(nullable id)defaultValue;

/**
 Constructs a property descriptor for an object type property with the specified keypath and default value and custom keyName to use for storage in NSUserDefaults.
 */
+ (BMSettingsPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath defaultValue:(nullable id)defaultValue keyName:(NSString *)keyName;

/**
 Constructs a property descriptor for an object type property with the specified keypath, value type and default value.
 */
+ (BMSettingsPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath valueType:(BMValueType)valueType defaultValue:(nullable id)defaultValue;

/**
 Constructs a property descriptor for an object type property with the specified keypath, valueType, default value and custom keyName to use for storage in NSUserDefaults.
 */
+ (BMSettingsPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath valueType:(BMValueType)valueType defaultValue:(nullable id)defaultValue keyName:(NSString *)keyName;

@end

NS_ASSUME_NONNULL_END
