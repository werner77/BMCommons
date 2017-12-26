//
//  NSObject+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 30/09/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "NSObject+BMCommons.h"

@implementation NSObject(BMCommons)

+ (void)bmPerformBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay  {
    if (block) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
    }
}

+ (void)bmPerformBlock:(id (^)(void))block onQueue:(dispatch_queue_t)queue withCompletion:(void (^)(id resultFromBlock))completion {
    if (block) {
        dispatch_async(queue, ^{
            id result = block();
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(result);
                });
            }
        });
    }
}

+ (void)bmPerformBlockInBackground:(id (^)(void))block withCompletion:(void (^)(id resultFromBlock))completion  {
    [self bmPerformBlock:block onQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) withCompletion:completion];
}

+ (void)bmPerformBlockOnMainThread:(void (^)(void))block waitUntilDone:(BOOL)waitUntilDone {
    if (block) {
        if ([NSThread isMainThread]) {
            block();
        } else {
            if (waitUntilDone) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    block();
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block();
                });
            }
        }
    }
}

+ (void)bmPerformBlockOnMainThread:(void (^)(void))block {
    [self bmPerformBlockOnMainThread:block waitUntilDone:NO];
}

- (void)bmPerformBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay  {
    [NSObject bmPerformBlock:block afterDelay:delay];
}

- (void)bmPerformBlockInBackground:(id (^)(void))block withCompletion:(void (^)(id resultFromBlock))completion  {
    [NSObject bmPerformBlockInBackground:block withCompletion:completion];
}

- (void)bmPerformBlock:(id (^)(void))block onQueue:(dispatch_queue_t)queue withCompletion:(void (^)(id resultFromBlock))completion {
    [NSObject bmPerformBlock:block onQueue:queue withCompletion:completion];
}

- (void)bmPerformBlockOnMainThread:(void (^)(void))block {
    [NSObject bmPerformBlockOnMainThread:block];
}

- (void)bmPerformBlockOnMainThread:(void (^)(void))block waitUntilDone:(BOOL)waitUntilDone {
    [NSObject bmPerformBlockOnMainThread:block waitUntilDone:waitUntilDone];
}

- (BOOL)bmPerformBlockOnCurrentRunloop:(void (^)(BOOL timeoutOccured))block whenPredicate:(BOOL (^)(void))predicatedBlock timeout:(NSTimeInterval)timeout {
    BOOL waited = NO;
    NSDate *startDate = nil;
    if (timeout > 0) {
        startDate = [NSDate date];
    }
    while (YES) {
        BOOL predicate = NO;
        if (predicatedBlock) {
            predicate = predicatedBlock();
        }
        if (predicate) {
            if (block) {
                block(NO);
            }
            break;
        } else {
            waited = YES;
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }

        BOOL timeoutOccured = (startDate != nil && (-[startDate timeIntervalSinceNow]) >= timeout);
        if (timeoutOccured) {
            if (block) {
                block(YES);
            }
            break;
        }
    }
    return !waited;
}

- (id)bmSafePerformSelector:(SEL)selector {
    void *args[0] = {};
    return [self performSelector:selector withArgs:args argCount:0 safe:YES];
}

- (id)bmSafePerformSelector:(SEL)selector withObject:(id)p1 {
    void *args[1] = {(__bridge void *)p1};
    return [self performSelector:selector withArgs:args argCount:1 safe:YES];
}


- (id)bmSafePerformSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 {
    void *args[2] = {(__bridge void *)p1, (__bridge void *)p2};
    return [self performSelector:selector withArgs:args argCount:2 safe:YES];
}

- (id)bmSafePerformSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 {
    void *args[3] = {(__bridge void *)p1, (__bridge void *)p2, (__bridge void *)p3};
    return [self performSelector:selector withArgs:args argCount:3 safe:YES];
}

- (id)bmSafePerformSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
                 withObject:(id)p4 {
    void *args[4] = {(__bridge void *)p1, (__bridge void *)p2, (__bridge void *)p3, (__bridge void *)p4};
    return [self performSelector:selector withArgs:args argCount:4 safe:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)bmPerformSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 {
    void *args[3] = {(__bridge void *)p1, (__bridge void *)p2, (__bridge void *)p3};
    return [self performSelector:selector withArgs:args argCount:3 safe:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)bmPerformSelector:(SEL)selector withObject:(id)p1 withObject:(id)p2 withObject:(id)p3
             withObject:(id)p4 {
    void *args[4] = {(__bridge void *)p1, (__bridge void *)p2, (__bridge void *)p3, (__bridge void *)p4};
    return [self performSelector:selector withArgs:args argCount:4 safe:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)performSelector:(SEL)selector withArgs:(void *)args argCount:(NSUInteger)argCount safe:(BOOL)safe {
    id __autoreleasing ret = nil;
    NSUInteger returnLength;
    void *buffer = [self invokeSelector:selector withArgs:args argSizes:nil argCount:argCount safe:safe returnLength:&returnLength pointerType:YES];
    if (returnLength == sizeof(id)) {
        memcpy((void*)&ret, buffer, returnLength);
    }
    return ret;
}

- (void *)bmInvokeSelector:(SEL)selector returnLength:(NSUInteger *)returnLength {
    return [self invokeSelector:selector withArgs:nil argSizes:nil argCount:0 safe:NO returnLength:returnLength];
}

- (void *)bmInvokeSelector:(SEL)selector withArg:(void *)p1 argSize:(NSUInteger)argSize returnLength:(NSUInteger *)returnLength {
    void *args[1] = { p1 };
    NSUInteger argSizes[1] = {argSize};
    return [self invokeSelector:selector withArgs:args argSizes:argSizes argCount:1 safe:NO returnLength:returnLength];
}

- (void *)bmInvokeSelector:(SEL)selector withArg:(void *)p1 argSize:(NSUInteger)argSize1 withArg:(void *)p2 argSize:(NSUInteger)argSize2 returnLength:(NSUInteger *)returnLength {
    void *args[2] = {p1, p2};
    NSUInteger argSizes[2] = {argSize1, argSize2};
    return [self invokeSelector:selector withArgs:args argSizes:argSizes argCount:2 safe:NO returnLength:returnLength];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void *)bmInvokeSelector:(SEL)selector withArgs:(void **)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount returnLength:(NSUInteger *)returnLength {
    return [self invokeSelector:selector withArgs:args argSizes:argSizes argCount:argCount safe:NO returnLength:returnLength];
}

- (void)bmInvokeSelector:(SEL)selector withArgs:(void *_Nonnull *_Nonnull)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount returnBuffer:(void *)returnBuffer returnLength:(NSUInteger)returnLength {
    return [self invokeSelector:selector withArgs:args argSizes:argSizes argCount:argCount returnBuffer:returnBuffer returnBufferCreationBlock:NULL returnSize:returnLength safe:NO pointerType:NO];
}

- (void *)bmSafeInvokeSelector:(SEL)selector returnLength:(NSUInteger *)returnLength {
    return [self invokeSelector:selector withArgs:nil argSizes:nil argCount:0 safe:YES returnLength:returnLength];
}

- (void *)bmSafeInvokeSelector:(SEL)selector withArg:(void *)p1 argSize:(NSUInteger)argSize returnLength:(NSUInteger *)returnLength {
    void *args[1] = { p1 };
    NSUInteger argSizes[1] = {argSize};
    return [self invokeSelector:selector withArgs:args argSizes:argSizes argCount:1 safe:YES returnLength:returnLength];
}

- (void *)bmSafeInvokeSelector:(SEL)selector withArg:(void *)p1 argSize:(NSUInteger)argSize1 withArg:(void *)p2 argSize:(NSUInteger)argSize2 returnLength:(NSUInteger *)returnLength {
    void *args[2] = {p1, p2};
    NSUInteger argSizes[2] = {argSize1, argSize2};
    return [self invokeSelector:selector withArgs:args argSizes:argSizes argCount:2 safe:YES returnLength:returnLength];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void *)bmSafeInvokeSelector:(SEL)selector withArgs:(void **)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount returnLength:(NSUInteger *)returnLength {
    return [self invokeSelector:selector withArgs:args argSizes:argSizes argCount:argCount safe:YES returnLength:returnLength];
}

- (void)bmSafeInvokeSelector:(SEL)selector withArgs:(void *_Nonnull *_Nonnull)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount returnBuffer:(void *)returnBuffer returnLength:(NSUInteger)returnLength {
    return [self invokeSelector:selector withArgs:args argSizes:argSizes argCount:argCount returnBuffer:returnBuffer returnBufferCreationBlock:NULL returnSize:returnLength safe:YES pointerType:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void *)invokeSelector:(SEL)selector withArgs:(void **)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount safe:(BOOL)safe returnLength:(NSUInteger *)returnLength {
    return [self invokeSelector:selector withArgs:args argSizes:argSizes argCount:argCount safe:safe returnLength:returnLength pointerType:NO];
}

- (void *)invokeSelector:(SEL)selector withArgs:(void **)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount safe:(BOOL)safe returnLength:(NSUInteger *)returnLength pointerType:(BOOL)pointerType {
    NSData __autoreleasing *data = [self dataFromInvokeSelector:selector withArgs:args argSizes:argSizes argCount:argCount safe:safe pointerType:pointerType];
    if (returnLength) {
        *returnLength = data.length;
    }
    return (void *)data.bytes;
}

- (NSData *)dataFromInvokeSelector:(SEL)selector withArgs:(void **)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount safe:(BOOL)safe pointerType:(BOOL)pointerType {
    
    __block void *buffer = NULL;
    __block NSUInteger bufferSize = 0;
    
    [self invokeSelector:selector withArgs:args argSizes:argSizes argCount:argCount returnBuffer:NULL returnBufferCreationBlock:^void *(NSUInteger size) {
        buffer = malloc(size);
        bufferSize = size;
        return buffer;
    } returnSize:0 safe:safe pointerType:pointerType];
    
    NSData *data = buffer == NULL ? nil : [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
    return data;
}

- (void)invokeSelector:(SEL)selector withArgs:(void **)args argSizes:(NSUInteger *)argSizes argCount:(NSUInteger)argCount returnBuffer:(void *)returnBuffer returnBufferCreationBlock:(void * (^)(NSUInteger size))returnBufferCreationBlock returnSize:(NSUInteger)returnSize safe:(BOOL)safe pointerType:(BOOL)pointerType {
    
    NSMethodSignature *sig = [self methodSignatureForSelector:selector];
    
    if (safe && ![self respondsToSelector:selector]) {
        return;
    }
    
    if (sig) {
        if (returnBufferCreationBlock == NULL) {
            if (sig.methodReturnLength != returnSize) {
                if (safe) {
                    return;
                } else {
                    NSString *message = @"Return size of method signature does not match specified size";
                    @throw [NSException exceptionWithName:@"BMInvalidArgumentException" reason:message userInfo:nil];
                }
            }
        } else {
            returnBuffer = NULL;
        }
        
        NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
        [invo setTarget:self];
        [invo setSelector:selector];
        
        if (args != nil) {
            for (NSUInteger i = 0; i < argCount; ++i) {
                void *arg = args[i];
                if (pointerType) {
                    [invo setArgument:&arg atIndex:(i + 2)];
                } else {
                    BOOL argSizeValid = YES;
                    if (argSizes != NULL) {
                        NSUInteger argSize = 0;
                        NSUInteger alignedArgSize = 0;
                        const char * argType = [sig getArgumentTypeAtIndex:(i + 2)];
                        
                        if (argType != NULL) {
                            NSGetSizeAndAlignment ( argType, &argSize, &alignedArgSize );
                        }
                        
                        if (argSize != argSizes[i]) {
                            argSizeValid = NO;
                        }
                    }
                    
                    if (argSizeValid) {
                        [invo setArgument:arg atIndex:(i + 2)];
                    } else {
                        if (safe) {
                            return;
                        } else {
                            NSString *message = [NSString stringWithFormat:@"Invalid size for argument at index %tu specified for selector %@", i, NSStringFromSelector(selector)];
                            @throw [NSException exceptionWithName:@"BMInvalidArgumentException" reason:message userInfo:nil];
                        }
                    }
                }
            }
        }
        [invo invoke];
        if (sig.methodReturnLength > 0) {
            if (returnBufferCreationBlock != NULL) {
                returnBuffer = returnBufferCreationBlock(sig.methodReturnLength);
            }
            [invo getReturnValue:returnBuffer];
        }
    } else {
        if (!safe) {
            [self doesNotRecognizeSelector:selector];
        }
    }
}

- (id)bmCastSafely:(Class)expectedClass {
    return [[self class] checkTypeSafetyForValue:self andClass:expectedClass];
}

- (id)bmProtocolCastSafely:(Protocol *)expectedProtocol {
    return [[self class] checkTypeSafelyForValue:self andProtocol:expectedProtocol];
}

- (NSString *)bmPrettyDescription {
    return [self description];
}

+ (id)checkTypeSafelyForValue:(id)value andProtocol:(Protocol *)expectedProtocol {
    if (value && ![value conformsToProtocol:expectedProtocol]) {
        value = nil;
    }
    return value;
}

+ (id)checkTypeSafetyForValue:(id)value andClass:(Class)clazz {
    if (value && ![value isKindOfClass:clazz]) {
        value = nil;
    }
    return value;
}

@end
