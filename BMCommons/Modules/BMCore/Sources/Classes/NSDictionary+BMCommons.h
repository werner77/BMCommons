//
//  NSDictionary+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 18/07/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMPropertyDescriptor;

NS_ASSUME_NONNULL_BEGIN

/**
 NSDictionary additions.
 */
@interface NSDictionary(BMCommons)

/**
 Type-safe version of objectForKey:. 
 
 The object is only returned if it meets isKindOfClass: for the supplied class.
 */
- (nullable id)bmObjectForKey:(id)aKey ofClass:(Class)c;

/**
 Retrieves a value from this dictionary via an XPath-like expression.
 
 Say you have:
 A dictionary with key=@"a", value=dictionary1 (dictionary1 is another NSDictionary).
 Dictionary1 contains: key=@"b", value=array1 (array1 is an NSArray).
 Array1 contains 2 strings @"c" and @"d".
 
 To retrieve the string @"d" you would specify the XPath: /a/b[1] or a/b[1].
 To retrieve the string @"c" you would specify the XPath: a/b[0]
 To retrieve array1 you would specify the XPath: a/b
 To retrieve dictionary1 you would specify the XPath: a
 
 @param xpath The XPath expression.
 */
- (nullable id)bmValueForXPath:(NSString *)xpath;

/**
 Type-safe version of bmValueForXPath:
 
 This method checks whether the return value is an instance of the specified class, otherwise nil is returned.
 */
- (nullable id)bmValueForXPath:(NSString *)xpath withClass:(Class)c;

/**
 Value transforming version of bmValueForXPath:
 
 This method supplies the return value to the specified valueTransformer for conversion. If the valueTransformer throws an exception, nil is returned, unless [NSObject isBMThrowAssertionExceptions] returns YES.
 */
- (nullable id)bmValueForXPath:(NSString *)xpath withValueTransformer:(NSValueTransformer *)valueTransformer;

/**
 Same as bmValueForXPath:withClass: but this method throws an exception instead of returning nil.
 */
- (id)bmRequiredValueForXPath:(NSString *)xpath withClass:(Class)c;

/**
 Same as bmValueForXPath:withValueTransformer: but this method throws an exception instead of returning nil.
 */
- (id)bmRequiredValueForXPath:(NSString *)xpath withValueTransformer:(NSValueTransformer *)valueTransformer;

/**
 Same as bmValueForXPath:withClass: but this method returns the default value instead of nil if the value could not be found.
 */
- (nullable id)bmValueForXPath:(NSString *)xpath withClass:(Class)c defaultValue:(id)defaultValue;

/**
 Same as bmValueForXPath:withValueTransformer: but this method returns the default value instead of nil if the value could not be found.
 */
- (nullable id)bmValueForXPath:(NSString *)xpath withValueTransformer:(NSValueTransformer *)valueTransformer defaultValue:(nullable id)defaultValue;

/**
 * Returns a dictionary containing the objects in the specified array as values and using the keyPropertyDescriptor for each object to construct the key for that object.
 *
 * This is a convenience method to create a lookup/caching dictionary where one property of the object acts as the index.
 */
+ (instancetype)bmDictionaryFromArray:(NSArray *)array withKeyPropertyDescriptor:(BMPropertyDescriptor *)pd;

/**
 * Returns a dictionary containing the objects in the specified array as values and using the keySelectorBlock for each object to construct the key for that object.
 *
 * This is a convenience method to create a lookup/caching dictionary where one property of the object acts as the index.
 */
+ (instancetype)bmDictionaryFromArray:(NSArray *)array withKeySelectorBlock:(id<NSCopying>(^)(id object))keySelectorBlock;

/**
 * Returns a deep mutable copy of the receiver by copying all the objects and keys in the receiver.
 */
- (NSMutableDictionary *)bmDeepMutableCopy;

@end

/**
 NSMutableDictionary additions.
 */
@interface NSMutableDictionary(BMCommons)

/**
 Checks both object and key to be non-nil before calling setObject:forKey:
 */
- (void)bmSafeSetObject:(nullable id)object forKey:(nullable id)key;

/**
 * Returns the object for the specified key if existent, else sets the object returned by the default constructer for this key and returns it.
 *
 * Note that the dictionary will contain an object for this key always if defaultConstructor returns a non-nil object.
 */
- (id)bmObjectForKey:(id)key withDefaultConstructor:(id (^)(void))constructor;

@end

NS_ASSUME_NONNULL_END
