//
//  BMErrorContainer.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/13/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Protocol defining an object containing an NSError.
 
 Useful for BMService implementations.
 
 @see [BMService service:failedWithError:]
 */

@protocol BMErrorContainer<NSObject>

/**
 * The error contained by this object.
 */
- (NSError *)error;

@end
