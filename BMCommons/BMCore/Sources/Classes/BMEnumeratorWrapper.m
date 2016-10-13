//
//  BMEnumeratorWrapper.m
//  BMCommons
//
//  Created by Werner Altewischer on 09/12/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMEnumeratorWrapper.h"


@implementation BMEnumeratorWrapper 

+ (BMEnumeratorWrapper *)enumeratorWrapperWithEnumerator:(NSEnumerator *)enumerator delegate:(id <BMEnumeratorDelegate>)theDelegate {
	return [[BMEnumeratorWrapper alloc] initWithEnumerator:enumerator delegate:theDelegate];
}

- (id)initWithEnumerator:(NSEnumerator *)theEnumerator delegate:(id <BMEnumeratorDelegate>)theDelegate {
	if ((self = [super init])) {
		_enumerator = theEnumerator;
		_delegate = theDelegate;
	}
	return self;
}

- (id)nextObject {
	id ret = [_enumerator nextObject];
	if (ret) {
		[_delegate enumerator:_enumerator didEnumerateObject:ret];
	}
	return ret;
}


@end
