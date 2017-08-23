//
//  BMErrorContainer.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/13/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol defining an object containing an NSError.
 
 Useful for BMService implementations.
 
 @see [BMService service:failedWithError:]
 */

@protocol BMErrorContainer<NSObject>

/**
 * The error contained by this object.
 */
- (nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
