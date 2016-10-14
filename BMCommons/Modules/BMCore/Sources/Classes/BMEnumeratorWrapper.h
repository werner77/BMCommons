//
//  BMEnumeratorWrapper.h
//  BMCommons
//
//  Created by Werner Altewischer on 09/12/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

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
@interface BMEnumeratorWrapper : NSEnumerator {
@private
	NSEnumerator *_enumerator;
	id <BMEnumeratorDelegate> _delegate;
}

+ (BMEnumeratorWrapper *)enumeratorWrapperWithEnumerator:(NSEnumerator *)enumerator delegate:(id <BMEnumeratorDelegate>)theDelegate;

- (id)initWithEnumerator:(NSEnumerator *)theEnumerator delegate:(id <BMEnumeratorDelegate>)theDelegate;

@end
