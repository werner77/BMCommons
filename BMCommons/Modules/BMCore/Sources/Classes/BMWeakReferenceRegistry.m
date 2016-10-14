//
//  BMWeakReferenceRegistry.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/3/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMWeakReferenceRegistry.h>
#import <BMCommons/BMWeakReference.h>

@interface BMWeakReferenceContext : NSObject

@property (nonatomic, strong) BMWeakReference *weakReference;
@property (nonatomic, copy) BMWeakReferenceCleanupBlock cleanupBlock;

- (BOOL)canBeCleanedUp;

@end

@implementation BMWeakReferenceContext

- (BOOL)canBeCleanedUp {
    return _weakReference.target == nil;
}

- (NSUInteger)hash {
    return (NSUInteger)self.weakReference.target;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[BMWeakReferenceContext class]]) {
        BMWeakReferenceContext *other = object;
        return other.weakReference.target == self.weakReference.target;
    }
    return NO;
}

@end

@implementation BMWeakReferenceRegistry {
    NSMutableArray *_referenceContexts;
    NSTimer *_timer;
}

BM_SYNTHESIZE_DEFAULT_SINGLETON(BMWeakReferenceRegistry)

- (id)init {
    if ((self = [super init])) {
        _referenceContexts = [NSMutableArray new];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(cleanupCheck:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)cleanupCheck:(NSTimer *)timer {
    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
    NSUInteger index = 0;
    
    @synchronized(self) {
        for (BMWeakReferenceContext *context in _referenceContexts) {
            if ([context canBeCleanedUp]) {
                if (context.cleanupBlock) {
                    context.cleanupBlock();
                }
                [discardedItems addIndex:index];
            }
            index++;
        }
        [_referenceContexts removeObjectsAtIndexes:discardedItems];
    }
}

- (void)registerReference:(id)reference withCleanupBlock:(BMWeakReferenceCleanupBlock)cleanup {
    if (reference && cleanup) {
        BMWeakReferenceContext *context = [BMWeakReferenceContext new];
        context.weakReference = [BMWeakReference weakReferenceWithTarget:reference];
        context.cleanupBlock = cleanup;
        
        @synchronized(self) {
            if (![_referenceContexts containsObject:context]) {
                [_referenceContexts addObject:context];
            }
        }
    }
}

- (void)deregisterReference:(id)reference {
    if (reference) {
        BMWeakReferenceContext *context = [BMWeakReferenceContext new];
        context.weakReference = [BMWeakReference weakReferenceWithTarget:reference];
        
        @synchronized(self) {
            [_referenceContexts removeObject:context];
        }
    }
}

@end
