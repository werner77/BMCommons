//
//  BMObjectToArrayTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 13/11/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Value transformer implementation which transforms an object to an array with one object.
 
 If the argument to transformedValue: is already an NSArray it is left untouched.
 This value transformer does not allow reverse transformation.
 */
@interface BMObjectToArrayTransformer : NSValueTransformer

@end
