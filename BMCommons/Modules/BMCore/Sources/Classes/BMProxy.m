//
//  BMProxy.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/15/11.
//  Copyright (c) 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMProxy.h>
#import <BMCommons/BMCore.h>

@implementation BMProxy {
@private
    __strong NSObject *_retainedObject;
}

@synthesize threadSafe = _threadSafe;
@synthesize object = _object;

+ (BMProxy *)proxyWithObject:(NSObject *)object threadSafe:(BOOL)threadSafe retained:(BOOL)retained {
    return [[BMProxy alloc] initWithObject:object threadSafe:threadSafe retained:retained];
}

- (id)initWithObject:(NSObject *)theObject {
    return [self initWithObject:theObject threadSafe:NO retained:YES];
}

- (id)initWithObject:(NSObject *)theObject threadSafe:(BOOL)b {
    return [self initWithObject:theObject threadSafe:b retained:YES];
}

- (id)initWithObject:(NSObject *)theObject threadSafe:(BOOL)b retained:(BOOL)retained {
    _object = theObject;
    if (retained) {
        _retainedObject = theObject;
    }
    self.threadSafe = b;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [_object methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if (self.threadSafe) {
        @synchronized(_object) {
            [anInvocation setTarget:_object];
            [anInvocation invoke];
        }
    } else {
        [anInvocation setTarget:_object];
        [anInvocation invoke];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL responds = [super respondsToSelector:aSelector];
	if (!responds) {
		responds = [_object respondsToSelector:aSelector];
	}
	return responds;
}

- (void)dealloc {
    BM_RELEASE_SAFELY(_retainedObject);
}

@end
