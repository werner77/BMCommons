//
//  BMWeakReferenceRegistry.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/3/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMWeakReferenceRegistry.h>
#import <BMCommons/BMWeakReference.h>
#import <objc/runtime.h>

@interface BMWeakReferenceContext : NSObject

@property (nonatomic, weak) id weakReference;
@property (nonatomic, weak) id owner;
@property (nonatomic, copy) BMWeakReferenceCleanupBlock cleanupBlock;

@end

@implementation BMWeakReferenceContext

- (instancetype)init {
    if ((self = [super init])) {
    }
    return self;
}

- (NSUInteger)hash {
    NSUInteger hash = ((NSUInteger)self.weakReference) * 17 + ((NSUInteger)self.owner);
    return hash;
}

- (BOOL)isEqual:(id)object {
    BOOL ret = NO;
    if ([object isKindOfClass:[BMWeakReferenceContext class]]) {
        BMWeakReferenceContext *other = object;
        ret = other.weakReference == self.weakReference && other.owner == self.owner;
    }
    return ret;
}

- (void)dealloc {
    //Object was deallocated: Do cleanup
    BMWeakReferenceCleanupBlock cleanupBlock = self.cleanupBlock;
    if (cleanupBlock) {
        cleanupBlock();
    }
}

@end

@interface NSObject(BMWeakReferenceRegistry)

- (void)bmAddWeakReferenceContext:(BMWeakReferenceContext *)context;
- (void)bmRemoveWeakReferenceContext:(BMWeakReferenceContext *)context;
- (void)bmRemoveWeakReferenceContexts;
- (void)bmRemoveWeakReferenceContextsWithPredicate:(BOOL (^)(BMWeakReferenceContext *))predicate;
- (BOOL)bmHasWeakReferenceContextWithPredicate:(BOOL (^)(BMWeakReferenceContext *))predicate;

@end

@implementation NSObject(BMWeakReferenceRegistry)

static char * const kBMWeakReferenceContextsKey = "com.behindmedia.bmcommons.NSObject.weakReferenceContexts";

- (NSMutableArray<BMWeakReferenceContext *> *)_bmWeakReferenceContexts {
    return objc_getAssociatedObject(self, kBMWeakReferenceContextsKey);
}

- (void)bmAddWeakReferenceContext:(BMWeakReferenceContext *)context {
    if (context != nil) {
        @synchronized (self) {
            NSMutableArray<BMWeakReferenceContext *> *contexts = [self _bmWeakReferenceContexts];
            if (contexts == nil) {
                contexts = [NSMutableArray new];
                objc_setAssociatedObject(self, kBMWeakReferenceContextsKey, contexts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            [contexts addObject:context];
        }
    }
}

- (void)bmRemoveWeakReferenceContexts {
    @synchronized (self) {
        [self._bmWeakReferenceContexts removeAllObjects];
    }
}

- (void)bmRemoveWeakReferenceContext:(BMWeakReferenceContext *)context {
    @synchronized (self) {
        [self._bmWeakReferenceContexts removeObjectIdenticalTo:context];
    }
}

- (void)bmRemoveWeakReferenceContextsWithPredicate:(BOOL (^)(BMWeakReferenceContext *))predicate {
    @synchronized (self) {
        [self._bmWeakReferenceContexts bmRemoveObjectsWithPredicate:predicate];
    }
}

- (BOOL)bmHasWeakReferenceContextWithPredicate:(BOOL (^)(BMWeakReferenceContext *))predicate {
    @synchronized (self) {
        return [self._bmWeakReferenceContexts bmFirstObjectWithPredicate:predicate] != nil;
    }
}

@end

@implementation BMWeakReferenceRegistry {
}

BM_SYNTHESIZE_DEFAULT_SINGLETON

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)registerReference:(id)reference forOwner:(id)owner withCleanupBlock:(BMWeakReferenceCleanupBlock)cleanup {
    if (reference && cleanup) {
        if (owner == nil) {
            owner = self;
        }
        BMWeakReferenceContext *context = [BMWeakReferenceContext new];
        context.weakReference = [BMWeakReference weakReferenceWithTarget:reference];
        context.owner = owner;
        context.cleanupBlock = cleanup;
        [reference bmAddWeakReferenceContext:context];
    }
}

- (void)deregisterReference:(id)reference forOwner:(id)owner {
    if (reference) {
        [reference bmRemoveWeakReferenceContextsWithPredicate:^BOOL(BMWeakReferenceContext *context) {
            return (owner == nil || context.owner == owner);
        }];
    }
}

- (BOOL)hasRegisteredReference:(id)reference forOwner:(id)owner {
    BOOL ret = NO;
    if (reference) {
        ret = [reference bmHasWeakReferenceContextWithPredicate:^BOOL(BMWeakReferenceContext *context) {
            return (owner == nil || context.owner == owner);
        }];
    }
    return ret;
}

@end
