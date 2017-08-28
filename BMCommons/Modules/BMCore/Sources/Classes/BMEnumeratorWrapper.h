//
//  BMEnumeratorWrapper.h
//  BMCommons
//
//  Created by Werner Altewischer on 09/12/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Delegate protocol for BMEnumeratorWrapper to be notified when objects are enumerated.
 */
@protocol BMEnumeratorDelegate

/**
 Message sent when the specified enumerator did enumerate the specified object.
 */
- (void)enumerator:(NSEnumerator *)enumerator didEnumerateObject:(id)object;

@end

/**
 Wrapper for an enumerator containing functionality to notify a delegate of the objects being enumerated.
 */
@interface BMEnumeratorWrapper : NSEnumerator

+ (BMEnumeratorWrapper *)enumeratorWrapperWithEnumerator:(NSEnumerator *)enumerator delegate:(nullable id <BMEnumeratorDelegate>)theDelegate;

/**
 * Intitializes with the specified enumerator and delegate.
 */
- (id)initWithEnumerator:(NSEnumerator *)theEnumerator delegate:(nullable id <BMEnumeratorDelegate>)theDelegate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
