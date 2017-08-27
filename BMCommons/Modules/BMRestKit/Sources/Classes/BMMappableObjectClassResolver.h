//
//  BMMappableObjectClassResolver.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/09/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class BMParserElement;

typedef NS_ENUM(NSUInteger, BMMappableObjectNameSpaceType) {
    BMMappableObjectNameSpaceTypeDefault = 0,
    BMMappableObjectNameSpaceTypeQualified = 1,
    BMMappableObjectNameSpaceTypeUnqualified = 2,
};


/**
 Protocol for mapping types including namespaces to mappable object classnames. 
 
 Because ObjectiveC doesn't have namespaces, every namespace needs to map to a unique prefix (or suffix, or something other that would make it unique).
 */
@protocol BMMappableObjectClassResolver <NSObject>

/**
 Gets the class name for the mappable object to map and it's parent class name if applicable from the specified type descriptor.
 
 An example of a descriptor would be com.somenamespace.SomeClass:com.someothernamespace.SomeParentClass which could map to BMQ1SomeClassDTO and BMQ2SomeParentClassDTO.
 */
- (BOOL)getMappableObjectClassName:(NSString * _Nullable * _Nonnull)mappableObjectClassName andParentClassName:(NSString * _Nullable * _Nonnull)parentClassName fromDescriptor:(NSString *)descriptor;

/**
 Gets a classname from the specified object type name and namespace.
 
 Example: objectType = SomeClass, namespace = com.somenamespace => classname = BMQ1SomeClassDTO.
 */
- (NSString *)mappableObjectClassNameForObjectType:(NSString *)objectType namespace:(nullable NSString *)theNamespace;

/**
 This could return something other than BMMAppableObjectNameSpaceTypeDefault to allow for overriding the namespace type encountered in XML documents.
 
 This is purely a feature to fix bugs in some server SOAP implementations.
 */
- (BMMappableObjectNameSpaceType)typeForNamespace:(nullable NSString *)theNamespace;

@end

NS_ASSUME_NONNULL_END
