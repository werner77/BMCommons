//
//  BMProxy.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/15/11.
//  Copyright (c) 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Proxy that delegates all messages to the specified object
 */
@interface BMProxy : NSProxy {
@private
    __weak NSObject *_object;
    __strong NSObject *_retainedObject;
    BOOL _threadSafe;
}

/**
 The target object of the proxy.
 */
@property(readonly, weak) NSObject *object;

/**
 Whether the proxy should be thread-safe (make all methods synchronized) or not.
 */
@property(atomic, assign) BOOL threadSafe;

/**
 Initializer with the designated target object.
 
 Defaults to threadSafe = NO and retained = YES.
 
 @param object The proxied object
 */
- (id)initWithObject:(NSObject *)object;

/**
 Initializer with the designated target object and whether the proxy should be thread-safe or not.
 
 Defaults to retained = YES.
 
 @param object The proxied object
 @param threadSafe Whether the proxy should synchronize all methods or not.
 */
- (id)initWithObject:(NSObject *)object threadSafe:(BOOL)threadSafe;

/**
 Designated initializer. 
 
 The retained parameter determines whether the target object is retained or not.
 */
- (id)initWithObject:(NSObject *)object threadSafe:(BOOL)threadSafe retained:(BOOL)retained;

+ (BMProxy *)proxyWithObject:(NSObject *)object threadSafe:(BOOL)threadSafe retained:(BOOL)retained;

@end
