//
//  BMObjectToStringTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 04/11/11.
//  Copyright (c) 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMPropertyDescriptor.h>

/**
 Value transformer for converting an object to a string representation.
 
 If propertyDescriptor is not set it returns the result of the description method of the object.
 If propertyDescriptor is set it calls the getter which the propertydescriptor references on the value supplied to transformedValue:.
 This value transformer does not allow reverse transformation.
 */
@interface BMObjectToStringTransformer : NSValueTransformer {
@private
    BMPropertyDescriptor *_propertyDescriptor;
}

@property (nonatomic, strong) BMPropertyDescriptor *propertyDescriptor;

- (id)initWithPropertyDescriptor:(BMPropertyDescriptor *)thePropertyDescriptor;

+ (BMObjectToStringTransformer *)transformerWithPropertyDescriptor:(BMPropertyDescriptor *)descriptor;

@end
