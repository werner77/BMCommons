//
//  BMPropertyDescriptor.h
//  BMCommons
//
//  Created by Werner Altewischer on 09/11/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreObject.h>
#import <BMCommons/BMValueType.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Class to describe/access a property on a specified target object.
 */
@interface BMPropertyDescriptor : BMCoreObject

/**
 The keyPath to the property.
 */
@property (nonatomic, strong) NSString *keyPath;

/**
 Ordered array of selector names for the getters for the specified property.
 
 If keyPath is multiple levels deep more than one getter may be present, one for each level.
 */
@property (nonatomic, readonly) NSArray *getters;

/**
 Selector name of the setter for the property.
 */
@property (nonatomic, readonly) NSString *setter;

/**
 The name of the leaf property. 
 
 This is the last part of the keypath or equal to the key path if the keypath is single level (contains no dots).
 */
@property (nonatomic, readonly) NSString *propertyName;

/**
 The target object to access the property from.
 */
@property (nullable, nonatomic, weak) NSObject *target;

/**
 Optional value transformer for converting the value before setting it (forward transformation) or converting it back before getting it (reverse transformation).
 
 This only works for object type properties.
 */
@property (nullable, nonatomic, strong) NSValueTransformer *valueTransformer;

/**
 In the case the property corresponds with a primitive value, its value type may be set here.
 
 This property may be used by callers to determine how to interpret the result of invokeGetter:
 */
@property (nonatomic, assign) BMValueType valueType;


/**
 Constructs and returns a property descriptor with the specified key path.
 */
+ (nullable BMPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath;

/**
 Constructs and returns a property descriptor with the specified key path and valueType.
 */
+ (nullable BMPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath valueType:(BMValueType)valueType;

/**
 Constructs and returns a property descriptor with the specified key path and target
 */
+ (nullable BMPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath withTarget:(nullable NSObject *)theTarget;

/**
  Constructs and returns a property descriptor with the specified key path and target and primitive value type. Use BMValueTypeObject for object typed properties.
  */
+ (nullable BMPropertyDescriptor *)propertyDescriptorFromKeyPath:(NSString *)theKeyPath withTarget:(nullable NSObject *)theTarget valueType:(BMValueType)valueType;

/**
 Initializer
 */
- (nullable id)initWithKeyPath:(NSString *)theKeyPath target:(id)theTarget;

- (nullable id)initWithKeyPath:(NSString *)theKeyPath target:(id)theTarget valueType:(BMValueType)valueType;

/**
 Calls the getter on the target and returns the value.
 */
- (nullable id)callGetter;

/**
 Calls the setter on the target with the specified value.
 */
- (void)callSetter:(nullable id)value;

/**
 Calls the getter on the target set by optionally ignoring any failures.
 */
- (nullable id)callGetterWithIgnoreFailure:(BOOL)ignoreFailure;

/**
 Calls the setter on the target set by optionally ignoring any failures.
 */
- (void)callSetter:(nullable id)value ignoreFailure:(BOOL)ignoreFailure;

/**
 Calls the getter on a specified target. 
 
 Fails if the property could not be found or read.
 */
- (nullable id)callGetterOnTarget:(id)target;

/**
 Calls the setter on a specified target with the specified value. 
 
 Fails if the property could not be found or written.
 */
- (void)callSetterOnTarget:(id)target withValue:(nullable id)value;

/**
 Calls the getter on a specified target, optionally ignoring a failure if the property could not be found or read.
 */
- (nullable id)callGetterOnTarget:(id)target ignoreFailure:(BOOL)ignoreFailure;

/**
 Calls the setter on a specified target, optionally ignoring a failure if the property could not be found or written.
 */
- (void)callSetterOnTarget:(id)target withValue:(nullable id)value ignoreFailure:(BOOL)ignoreFailure;

/**
 Validates the value corresponding with the property using KVO validation methods. 
 
 Returns true if valid, false otherwise with the error object set.
 */
- (BOOL)validateValue:(id _Nullable * _Nonnull)value withError:(NSError **)error;

/**
 Validates the value corresponding with the property using KVO validation methods. 
 
 Returns true if valid, false otherwise with the error object set.
 */
- (BOOL)validateValue:(id _Nullable* _Nonnull)value onTarget:(nullable id)target withError:(NSError **)error;

/**
 Returns the descriptor for the parent property in case the keypath contains more than 1 components or nil otherwise.
 */
- (nullable BMPropertyDescriptor *)parentDescriptor;

/**
 Invokes getter for returning the raw value. 
 
 Use this for primitive value types for example.
 Any ValueTransformer set is ignored.
 This returns a pointer to an autoreleased buffer with the length returned in the valueLength parameter.
 
 @see invokeGetterOnTarget:ignoreFailure:valueLength:
 */
- (nullable void *)invokeGetterWithValueLength:(NSUInteger *)valueLength;

/**
 Invokes setter.
 Use this for primitive value types for example.
 Any ValueTransformer set is ignored.
 
 @see invokeSetterOnTarget:withValue:ignoreFailure:
 */
- (void)invokeSetter:(void *)value valueLength:(NSUInteger)valueLength;

/**
 
 @see invokeGetterOnTarget:ignoreFailure:valueLength:
 */
- (nullable void *)invokeGetterOnTarget:(id)t valueLength:(NSUInteger *)valueLength;

/**
 
 @see invokeSetterOnTarget:withValue:ignoreFailure:
 */
- (void)invokeSetterOnTarget:(id)t withValue:(void *)value valueLength:(NSUInteger)valueLength;

/**
 
 @see invokeGetterOnTarget:ignoreFailure:valueLength:
 */
- (nullable void *)invokeGetterWithIgnoreFailure:(BOOL)ignoreFailure valueLength:(NSUInteger *)valueLength;

/**
 @see invokeSetterOnTarget:withValue:ignoreFailure:
 */
- (void)invokeSetter:(void *)value valueLength:(NSUInteger)valueLength ignoreFailure:(BOOL)ignoreFailure;

/**
 Invokes setter on the specified target using the raw value supplied by the value argument. This method can be used to supply primitive values instead of id values.
 Optionally ignoreFailures may be set to ignore exceptions.
 */
- (void)invokeSetterOnTarget:(id)t withValue:(void *)value valueLength:(NSUInteger)valueLength ignoreFailure:(BOOL)ignoreFailure;


/**
 Invokes getter for returning the raw value. Use this for primitive value types for example. Any ValueTransformer set is ignored.
 
 This method returns a pointer to an autoreleased buffer containing the return value. The length of the return value may be retrieved from the valueLength argument supplied to this method.
 */
- (void * _Nullable)invokeGetterOnTarget:(id)t ignoreFailure:(BOOL)ignoreFailure valueLength:(NSUInteger *)valueLength;

@end

NS_ASSUME_NONNULL_END

