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
@property (nonatomic, copy) BMWeakReferenceCleanupBlock cleanupBlock;

@end

@interface NSObject(BMWeakReferenceRegistry)

- (void)bmAddWeakReferenceContext:(BMWeakReferenceContext *)context;
- (void)bmRemoveWeakReferenceContexts;

@end

@implementation BMWeakReferenceContext

- (NSUInteger)hash {
    NSUInteger hash = ((NSUInteger)self.weakReference);
    return hash;
}

- (BOOL)isEqual:(id)object {
    BOOL ret = NO;
    if ([object isKindOfClass:[BMWeakReferenceContext class]]) {
        BMWeakReferenceContext *other = object;
        ret = (other.weakReference == self.weakReference);
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

@end


@implementation BMWeakReferenceRegistry {
}

BM_SYNTHESIZE_DEFAULT_SINGLETON

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)registerReference:(id)reference withCleanupBlock:(BMWeakReferenceCleanupBlock)cleanup {
    if (reference && cleanup) {
        BMWeakReferenceContext *context = [BMWeakReferenceContext new];
        context.weakReference = [BMWeakReference weakReferenceWithTarget:reference];
        context.cleanupBlock = cleanup;
        [reference bmAddWeakReferenceContext:context];
    }
}

- (void)deregisterReference:(id)reference {
    [reference bmRemoveWeakReferenceContexts];
}

@end
