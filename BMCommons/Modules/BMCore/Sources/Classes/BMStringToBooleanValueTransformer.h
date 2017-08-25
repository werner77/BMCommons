//
//  BMStringToBooleanValueTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/16/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Transformer for converting a string to a boolean and vice versa.
 
 It follows the rules of the [NSString boolValue] method for returning true or false.
 
 @see [NSString boolValue]
 */
@interface BMStringToBooleanValueTransformer : NSValueTransformer {

}

@end

NS_ASSUME_NONNULL_END
