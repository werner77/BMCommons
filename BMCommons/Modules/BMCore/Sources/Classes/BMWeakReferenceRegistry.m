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
@property (nonatomic, weak) id owner;
@property (nonatomic, copy) BMWeakReferenceCleanupBlock cleanupBlock;

- (BOOL)canBeCleanedUp;

@end

@implementation BMWeakReferenceContext

- (BOOL)canBeCleanedUp {
    return _weakReference.target == nil;
}

- (NSUInteger)hash {
    NSUInteger hash = ((NSUInteger)self.weakReference.target) * 17 + ((NSUInteger)self.owner);
    return hash;
}

- (BOOL)isEqual:(id)object {
    BOOL ret = NO;
    if ([object isKindOfClass:[BMWeakReferenceContext class]]) {
        BMWeakReferenceContext *other = object;
        ret = other.weakReference.target == self.weakReference.target && other.owner == self.owner;
    }
    return ret;
}

@end

@implementation BMWeakReferenceRegistry {
    NSMutableArray *_referenceContexts;
    NSTimer *_timer;
}

BM_SYNTHESIZE_DEFAULT_UNIQUE_SINGLETON

- (id)init {
    if ((self = [super init])) {
        _referenceContexts = [NSMutableArray new];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(cleanupCheck:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)cleanupCheck:(NSTimer *)timer {
    @synchronized(self) {
        [_referenceContexts bmRemoveObjectsWithPredicate:^BOOL(BMWeakReferenceContext *context) {
            BOOL ret = NO;
            if ([context canBeCleanedUp]) {
                if (context.cleanupBlock) {
                    context.cleanupBlock();
                }
                ret = YES;
            }
            return ret;
        }];
    }
}

- (void)registerReference:(id)reference forOwner:(id)owner withCleanupBlock:(BMWeakReferenceCleanupBlock)cleanup {
    if (reference && cleanup) {
        BMWeakReferenceContext *context = [BMWeakReferenceContext new];
        context.weakReference = [BMWeakReference weakReferenceWithTarget:reference];
        context.owner = owner;
        context.cleanupBlock = cleanup;

        @synchronized(self) {
            [_referenceContexts addObject:context];
        }
    }
}

- (void)deregisterReference:(id)reference forOwner:(id)owner {
    if (reference) {
        @synchronized(self) {
            [_referenceContexts bmRemoveObjectsWithPredicate:^BOOL(BMWeakReferenceContext *context) {
                return (owner == nil || context.owner == owner) && context.weakReference.target == reference;
            }];
        }
    }
}

- (void)deregisterReferencesForOwner:(id)owner {
    @synchronized(self) {
        [_referenceContexts bmRemoveObjectsWithPredicate:^BOOL(BMWeakReferenceContext *context) {
            return (owner == nil || context.owner == owner);
        }];
    }
}

@end
