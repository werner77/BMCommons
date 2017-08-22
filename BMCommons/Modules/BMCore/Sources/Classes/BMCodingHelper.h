//
//  BMCodingHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMPropertyDescriptor.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Helper to encode/decode objects using NSCoding based on BMPropertyDescriptor.
 */
@interface BMCodingHelper : NSObject

/**
 Encodes the properties specified by the propertyDescriptors (instances of BMPropertyDescriptor) using the specified coder using keyed coding.
 
 If target is nil, the target set in the property descriptors is used if any.
 */
+ (void)encodePropertiesFromDescriptors:(NSArray *)propertyDescriptors withCoder:(NSCoder *)coder forTarget:(nullable id)target;

/**
 Decodes the properties specified by the propertyDescriptors (instances of BMPropertyDescriptor) using the specified coder using keyed coding.
 
 If target is nil, the target set in the property descriptors is used if any.
 */
+ (void)decodePropertiesFromDescriptors:(NSArray *)propertyDescriptors withCoder:(NSCoder *)coder forTarget:(nullable id)target;

@end

NS_ASSUME_NONNULL_END