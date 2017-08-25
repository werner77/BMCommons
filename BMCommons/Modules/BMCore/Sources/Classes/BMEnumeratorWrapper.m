//
//  BMEnumeratorWrapper.m
//  BMCommons
//
//  Created by Werner Altewischer on 09/12/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMEnumeratorWrapper.h>


@implementation BMEnumeratorWrapper {
@private
	NSEnumerator *_enumerator;
	id <BMEnumeratorDelegate> _delegate;
}

+ (BMEnumeratorWrapper *)enumeratorWrapperWithEnumerator:(NSEnumerator *)enumerator delegate:(id <BMEnumeratorDelegate>)theDelegate {
	return [[BMEnumeratorWrapper alloc] initWithEnumerator:enumerator delegate:theDelegate];
}

- (id)initWithEnumerator:(NSEnumerator *)theEnumerator delegate:(id <BMEnumeratorDelegate>)theDelegate {
	if ((self = [super init])) {
		_enumerator = theEnumerator;

		if (!_enumerator) {
			return nil;
		}

		_delegate = theDelegate;
	}
	return self;
}

- (id)init {
	return [self initWithEnumerator:nil delegate:nil];
}

- (id)nextObject {
	id ret = [_enumerator nextObject];
	if (ret) {
		[_delegate enumerator:_enumerator didEnumerateObject:ret];
	}
	return ret;
}


@end
