//
//  BMObjectHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 31/08/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMCoreObject.h>
#import <BMCore/BMDigest.h>

/**
 Object helper methods
 */
@interface BMObjectHelper : BMCoreObject {
	
}

/**
 Returns nil in case the object == [NSNull null], otherwise the object itself.
 */
+ (id)filterNSNullObject:(id)object;

/**
 Returns [NSNull null] in case nil is supplied, otherwise the object itself.
 */
+ (id)filterNullObject:(id)object;

/**
 Returns the default value in case the object supplied is nil, other wise the object itself is returned.
 */
+ (id)filterNullObject:(id)object withDefaultValue:(id)defaultValue;

/**
 Checks whether key and object or not nil before setting them in the specified dictionary.
 */
+ (void)setObject:(id)object forKey:(id)aKey inDictionary:(NSMutableDictionary *)dict;

/**
 Calls the KVO validation methods for the specified array of attributes. 
 
 @param object The object to call the KVO validation methods on
 @param attributes The name of the attributes for which to call the KVO method [NSObject valueForKey:] should resolve for each attribute supplied.
 @param error On error this object is filled.
 @return YES if successful and NO otherwise. In the latter case the error is set. The error is the first validation failure for the attribute array.
 */
+ (BOOL)validateObject:(id)object attributes:(NSArray *)attributes withError:(NSError **)error;

/**
 Returns true iff value1/value2 returned for the keypaths (instances of NSString) supplied for object1/object2 obey the condition: value1 == value2 || [value1 isEqual:value2].
 */
+ (BOOL)isObject:(id)object1 equalToObject:(id)object2 forKeyPaths:(NSArray *)keyPaths;

/**
 Returns true iff value1/value2 returned for the array of property descriptors supplied for object1/object2 obey the condition: value1 == value2 || [value1 isEqual:value2].
 */
+ (BOOL)isObject:(id)object1 equalToObject:(id)object2 forPropertyDescriptors:(NSArray *)propertyDescriptors;

/**
 Returns a hash code for the specified object using the specified keypaths. The order of the keypaths matters.
 */
+ (NSUInteger)hashCodeForObject:(id)object withKeyPaths:(NSArray *)keyPaths;

/**
 Returns a hash code for the specified object using the specified property descriptors. The order of the descriptors matters.
 */
+ (NSUInteger)hashCodeForObject:(id)object withPropertyDescriptors:(NSArray *)propertyDescriptors;

/**
 Returns a digest of the specified type for the specified object using the specified property descriptors. The order of the descriptors matters.
 */
+ (NSString *)digestOfType:(BMDigestType)digestType forObject:(id)object withPropertyDescriptors:(NSArray *)propertyDescriptors;

/**
 Returns a digest of the specified type for the specified object using the specified keypaths. The order of the keypaths matters.
 */
+ (NSString *)digestOfType:(BMDigestType)digestType forObject:(id)object withKeyPaths:(NSArray *)keyPaths;

@end
