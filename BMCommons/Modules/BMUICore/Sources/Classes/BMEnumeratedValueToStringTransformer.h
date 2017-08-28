//
//  BMEnumeratedValueToStringTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/24/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Value transformer for transforming an enumerated value to a string.
 
 By default the value of [BMEnumeratedValue label] is returned or, if this returns an empty or nil string, the value transformed to a string using the [BMEnumeratedValue valueTransformer].
 @see BMEnumeratedValue
 */
@interface BMEnumeratedValueToStringTransformer : NSValueTransformer {

}

@end

NS_ASSUME_NONNULL_END
