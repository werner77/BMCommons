//
//  NSObject+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 30/09/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

//Macro for safe copying the return value of the invoke selector methods
#define BM_SAFE_COPY_VALUE(type, source, dest, length) ({ if (length == sizeof(type)) {memcpy(dest, source, length);}})

/**
 NSObject additions.
 */
@interface NSObject(BMCommons)

/**
 Performs a block in the main thread after a specific delay.
 */
- (void)bmPerformBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

/**
 Performs the specified block in a background thread and once completed calls the completion block in the main thread with the result from the background block.
 */
- (void)bmPerformBlockInBackground:(id (^)(void))block withCompletion:(void (^)(id resultFromBlock))completion;

/**
 Performs the specified block asynchronously on the specified queue. Calls the completion block on the main thread when done.
 */
- (void)bmPerformBlock:(id (^)(void))block onQueue:(dispatch_queue_t)queue withCompletion:(void (^)(id resultFromBlock))completion;

/**
 Performs the specified block on the main thread. If called from the main thread it will execute immediately, else it will be scheduled using GCD.
 */
- (void)bmPerformBlockOnMainThread:(void (^)(void))block;

/**
 Performs the specified block on the main thread and optionally waits for it to complete.
 */
- (void)bmPerformBlockOnMainThread:(void (^)(void))block waitUntilDone:(BOOL)waitUntilDone;

/**
 Class method equivalents to instance methods.
 */
+ (void)bmPerformBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

+ (void)bmPerformBlockInBackground:(id (^)(void))block withCompletion:(void (^)(id resultFromBlock))completion;

+ (void)bmPerformBlock:(id (^)(void))block onQueue:(dispatch_queue_t)queue withCompletion:(void (^)(id resultFromBlock))completion;

+ (void)bmPerformBlockOnMainThread:(void (^)(void))block;

+ (void)bmPerformBlockOnMainThread:(void (^)(void))block waitUntilDone:(BOOL)waitUntilDone;


/**
 Perform selector method with multiple args.
 */
- (id)bmPerformSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3;

/**
 Perform selector method with multiple args.
 */
- (id)bmPerformSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
             withObject:(id)p4;


/**
 Safe perform selector method.
 
 Instead of failing with an NSInvalidArgumentException if the specified selector does not exist, this method will just fail silently and return nil instead.
 */
- (id)bmSafePerformSelector:(SEL)selector;


/**
 Safe perform selector method.
 
 Instead of failing with an NSInvalidArgumentException if the specified selector does not exist, this method will just fail silently and return nil instead.
 */
- (id)bmSafePerformSelector:(SEL)selector withObject:(id)p1;


/**
 Perform selector method with multiple args.
 
 Instead of failing with an NSInvalidArgumentException if the specified selector does not exist, this method will just fail silently and return nil instead.
 */
- (id)bmSafePerformSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2;

/**
 Perform selector method with multiple args.
 
 Instead of failing with an NSInvalidArgumentException if the specified selector does not exist, this method will just fail silently and return nil instead.
 */
- (id)bmSafePerformSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3;

/**
 Perform selector method with multiple args.
 
 Instead of failing with an NSInvalidArgumentException if the specified selector does not exist, this method will just fail silently and return nil instead.
 */
- (id)bmSafePerformSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
                 withObject:(id)p4;


/**
 Invoke selector.
 
 Compared to performSelector this also allows for primitive types.
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (void *)bmInvokeSelector:(SEL)selector returnLength:(NSUInteger *)returnLength;

/**
 Invoke selector.
 
 Compared to performSelector this also allows for primitive types.
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (void *)bmInvokeSelector:(SEL)selector withArg:(void *)p1 argSize:(NSUInteger)argSize returnLength:(NSUInteger *)returnLength;

/**
 Invoke selector with multiple args.
 
 Compared to performSelector this also allows for primitive types.
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (void *)bmInvokeSelector:(SEL)selector withArg:(void *)p1 argSize:(NSUInteger)argSize1 withArg:(void *)p2 argSize:(NSUInteger)argSize2 returnLength:(NSUInteger *)returnLength;

/**
 Invoke selector with multiple args. Compared to performSelector this also allows for primitive types. The void* arguments specified by the array args are supplied as is to NSInvocation as method arguments. For supplying id arguments you have to supply the address of the id (that is &id) for primitives the address of the primitive argument.
 
 The return value is a pointer to an autoreleased buffer holding the return value of the invoked method. The size of the buffer is returned in the argument returnLength. Caller may copy the value from this buffer using memcopy for example.
 */
- (void *)bmInvokeSelector:(SEL)selector withArgs:(void **)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount returnLength:(NSUInteger *)returnLength;

/**
 Safe invoke selector method.
 
 Instead of failing with an NSInvalidArgumentException these methods will just return nil and fail silently if the selector does not exist.
 
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (void *)bmSafeInvokeSelector:(SEL)selector returnLength:(NSUInteger *)returnLength;

/**
 Safe invoke selector method.
 
 Instead of failing with an NSInvalidArgumentException these methods will just return nil and fail silently if the selector does not exist.
 
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (void *)bmSafeInvokeSelector:(SEL)selector withArg:(void *)p1 argSize:(NSUInteger)argSize returnLength:(NSUInteger *)returnLength;

/**
 Safe invoke selector method.
 
 Instead of failing with an NSInvalidArgumentException these methods will just return nil and fail silently if the selector does not exist.
 
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (void *)bmSafeInvokeSelector:(SEL)selector withArg:(void *)p1 argSize:(NSUInteger)argSize1 withArg:(void *)p2 argSize:(NSUInteger)argSize2 returnLength:(NSUInteger *)returnLength;

/**
 Safe invoke selector method.
 
 Instead of failing with an NSInvalidArgumentException these methods will just return nil and fail silently if the selector does not exist.
 
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (void *)bmSafeInvokeSelector:(SEL)selector withArgs:(void **)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount returnLength:(NSUInteger *)returnLength;

/**
 Performs a safe cast: checks whether this object is an instance of the supplied class, if not returns nil.
 */
- (id)bmCastSafely:(Class)expectedClass;

/**
 Performs a safe cast: checks whether this object conforms to the specified protocol, if not returns nil.
 */
- (id)bmProtocolCastSafely:(Protocol *)expectedProtocol;

/**
 * Defaults to [self description], may be overridden for a nicer representation if needed.
 *
 * @return
 */
- (NSString *)bmPrettyDescription;

@end
