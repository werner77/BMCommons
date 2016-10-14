//
//  BMPropertyMethod.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/15/11.
//  Copyright (c) 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreObject.h>

/**
 Class that describes a property accessor method.
 
 This class represents either the getter or the setter, not both.
 */
@interface BMPropertyMethod : BMCoreObject {
    @private
	BOOL _setter;
	NSString *_propertyName;
}

/**
 Returns YES is the property method is a setter, NO otherwise.
 */
@property(nonatomic, readonly, getter=isSetter) BOOL setter;

/**
 The name of the property this class represents.
 */
@property(nonatomic, readonly) NSString *propertyName;

/**
 Returns an auto-released instance calling initWithSelector
 */
+ (BMPropertyMethod *)propertyMethodFromSelector:(SEL)selector;

/**
 Parses the specified selector and returns a PropertyMethod instance describing this selector iff the selector is a property accessor method.
 
 If the selector is no property accessor (has more than one argument for example, or does not start with a lowercase char) nil is returned.
 This method recognizes both is-style getter properties (for booleans) and normal properties.
 
 @param selector The selector for the property method
 */
- (id)initWithSelector:(SEL)selector;

/**
 Initializes with the supplied property name.
 
 @param propertyName The name of the property
 @param isSetter whether The setter or the getter method should be represented by the returned BMPropertyMethod
 */
- (id)initWithPropertyName:(NSString *)propertyName setter:(BOOL)isSetter;

@end
