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

NS_ASSUME_NONNULL_BEGIN

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
- (void)bmPerformBlockInBackground:(id _Nullable (^)(void))block withCompletion:(void (^ _Nullable)(id _Nullable resultFromBlock))completion;

/**
 Performs the specified block asynchronously on the specified queue. Calls the completion block on the main thread when done.
 */
- (void)bmPerformBlock:(id _Nullable (^)(void))block onQueue:(dispatch_queue_t)queue withCompletion:(void (^ _Nullable )(id _Nullable resultFromBlock))completion;

/**
 Performs the specified block on the main thread. If called from the main thread it will execute immediately, else it will be scheduled using GCD.
 */
- (void)bmPerformBlockOnMainThread:(void (^)(void))block;

/**
 Performs the specified block on the main thread and optionally waits for it to complete.
 */
- (void)bmPerformBlockOnMainThread:(void (^)(void))block waitUntilDone:(BOOL)waitUntilDone;

/**
 * Runs the current runloop until the specified predicate block returns true.
 * If timeout > 0 this is the maximum number of seconds to wait for the predicate.
 *
 * @param block The block to execute. If timeoutOccured, the timeoutOccured boolean passed to the block while be true.
 * @param predicatedBlock The boolean condition to wait for.
 * @param timeout If > 0 an upper limit to the wait time.
 * @return YES if the block was run immediately (predicate was true already), false if a wait has to occur.
 */
- (BOOL)bmPerformBlockOnCurrentRunloop:(void (^)(BOOL timeoutOccured))block whenPredicate:(BOOL (^)(void))predicatedBlock timeout:(NSTimeInterval)timeout;

/**
 Class method equivalent to instance methods.
 */
+ (void)bmPerformBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

/**
 Class method equivalent to instance methods.
 */
+ (void)bmPerformBlockInBackground:(id _Nullable (^)(void))block withCompletion:(void (^)(id _Nullable resultFromBlock))completion;

/**
 Class method equivalent to instance methods.
 */
+ (void)bmPerformBlock:(id _Nullable (^)(void))block onQueue:(dispatch_queue_t)queue withCompletion:(void (^)(id _Nullable resultFromBlock))completion;

/**
 Class method equivalent to instance methods.
 */
+ (void)bmPerformBlockOnMainThread:(void (^)(void))block;

/**
 Class method equivalent to instance methods.
 */
+ (void)bmPerformBlockOnMainThread:(void (^)(void))block waitUntilDone:(BOOL)waitUntilDone;

/**
 Perform selector method with multiple args.
 */
- (nullable id)bmPerformSelector:(SEL)selector withObject:(nullable id)p1 withObject:(nullable id)p2 withObject:(nullable id)p3;

/**
 Perform selector method with multiple args.
 */
- (nullable id)bmPerformSelector:(SEL)selector withObject:(nullable id)p1 withObject:(nullable id)p2 withObject:(nullable id)p3
             withObject:(nullable id)p4;


/**
 Safe perform selector method.
 
 Instead of failing with an NSInvalidArgumentException if the specified selector does not exist, this method will just fail silently and return nil instead.
 */
- (nullable id)bmSafePerformSelector:(SEL)selector;


/**
 Safe perform selector method.
 
 Instead of failing with an NSInvalidArgumentException if the specified selector does not exist, this method will just fail silently and return nil instead.
 */
- (nullable id)bmSafePerformSelector:(SEL)selector withObject:(nullable id)p1;


/**
 Perform selector method with multiple args.
 
 Instead of failing with an NSInvalidArgumentException if the specified selector does not exist, this method will just fail silently and return nil instead.
 */
- (nullable id)bmSafePerformSelector:(SEL)selector withObject:(nullable id)p1 withObject:(nullable id)p2;

/**
 Perform selector method with multiple args.
 
 Instead of failing with an NSInvalidArgumentException if the specified selector does not exist, this method will just fail silently and return nil instead.
 */
- (nullable id)bmSafePerformSelector:(SEL)selector withObject:(nullable id)p1 withObject:(nullable id)p2 withObject:(nullable id)p3;

/**
 Perform selector method with multiple args.
 
 Instead of failing with an NSInvalidArgumentException if the specified selector does not exist, this method will just fail silently and return nil instead.
 */
- (nullable id)bmSafePerformSelector:(SEL)selector withObject:(nullable id)p1 withObject:(nullable id)p2 withObject:(nullable id)p3
                 withObject:(nullable id)p4;


/**
 Invoke selector.
 
 Compared to performSelector this also allows for primitive types.
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (nullable void *)bmInvokeSelector:(SEL)selector returnLength:(nullable NSUInteger *)returnLength;

/**
 Invoke selector.
 
 Compared to performSelector this also allows for primitive types.
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (nullable void *)bmInvokeSelector:(SEL)selector withArg:(void *)p1 argSize:(NSUInteger)argSize returnLength:(nullable NSUInteger *)returnLength;

/**
 Invoke selector with multiple args.
 
 Compared to performSelector this also allows for primitive types.
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (nullable void *)bmInvokeSelector:(SEL)selector withArg:(void *)p1 argSize:(NSUInteger)argSize1 withArg:(void *)p2 argSize:(NSUInteger)argSize2 returnLength:(nullable NSUInteger *)returnLength;

/**
 Invoke selector with multiple args. Compared to performSelector this also allows for primitive types. The void* arguments specified by the array args are supplied as is to NSInvocation as method arguments. For supplying id arguments you have to supply the address of the id (that is &id) for primitives the address of the primitive argument.
 
 The return value is a pointer to an autoreleased buffer holding the return value of the invoked method. The size of the buffer is returned in the argument returnLength. Caller may copy the value from this buffer using memcopy for example.
 */
- (nullable void *)bmInvokeSelector:(SEL)selector withArgs:(void *_Nonnull *_Nonnull)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount returnLength:(nullable NSUInteger *)returnLength;

/**
 Invoke selector with multiple args. Compared to performSelector this also allows for primitive types. The void* arguments specified by the array args are supplied as is to NSInvocation as method arguments. For supplying id arguments you have to supply the address of the id (that is &id) for primitives the address of the primitive argument.
 
 The returnBuffer supplied should be of length returnLength. The returnLength is checked with the method signature for safety.
 */
- (void)bmInvokeSelector:(SEL)selector withArgs:(void *_Nonnull *_Nonnull)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount returnBuffer:(void *)returnBuffer returnLength:(NSUInteger)returnLength;


/**
 Safe invoke selector method.
 
 Instead of failing with an NSInvalidArgumentException these methods will just return nil and fail silently if the selector does not exist.
 
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (nullable void *)bmSafeInvokeSelector:(SEL)selector returnLength:(nullable NSUInteger *)returnLength;

/**
 Safe invoke selector method.
 
 Instead of failing with an NSInvalidArgumentException these methods will just return nil and fail silently if the selector does not exist.
 
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (nullable void *)bmSafeInvokeSelector:(SEL)selector withArg:(void *)p1 argSize:(NSUInteger)argSize returnLength:(nullable NSUInteger *)returnLength;

/**
 Safe invoke selector method.
 
 Instead of failing with an NSInvalidArgumentException these methods will just return nil and fail silently if the selector does not exist.
 
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (nullable void *)bmSafeInvokeSelector:(SEL)selector withArg:(void *)p1 argSize:(NSUInteger)argSize1 withArg:(void *)p2 argSize:(NSUInteger)argSize2 returnLength:(nullable NSUInteger *)returnLength;

/**
 Safe invoke selector method.
 
 Instead of failing with an NSInvalidArgumentException these methods will just return nil and fail silently if the selector does not exist.
 
 @see invokeSelector:withArgs:argCount:returnLength:
 */
- (nullable void *)bmSafeInvokeSelector:(SEL)selector withArgs:(void *_Nonnull *_Nonnull)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount returnLength:(nullable NSUInteger *)returnLength;

/**
 Safe invoke selector method.
 
 Instead of failing with an NSInvalidArgumentException these methods will just return nil and fail silently if the selector does not exist.
 */
- (void)bmSafeInvokeSelector:(SEL)selector withArgs:(void *_Nonnull *_Nonnull)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount returnBuffer:(void *)returbBuffer returnLength:(NSUInteger)returnLength;

/**
 Performs a safe cast: checks whether this object is an instance of the supplied class, if not returns nil.
 */
- (nullable id)bmCastSafely:(Class)expectedClass;

/**
 Performs a safe cast: checks whether this object conforms to the specified protocol, if not returns nil.
 */
- (nullable id)bmProtocolCastSafely:(Protocol *)expectedProtocol;

/**
 * Defaults to [self description], may be overridden for a nicer representation if needed.
 */
- (NSString *)bmPrettyDescription;

@end

NS_ASSUME_NONNULL_END
