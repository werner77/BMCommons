//
//  BMWeakReference.h
//  BMCommons
//
//  Created by Werner Altewischer on 11/28/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Wrapper around a weak reference to a target object.
 */
@interface BMWeakReference : NSObject

@property (nullable, weak) id target;

+ (BMWeakReference *)weakReferenceWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
