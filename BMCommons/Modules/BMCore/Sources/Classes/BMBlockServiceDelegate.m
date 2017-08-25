//
//  BMBlockServiceDelegate.m
//  BMCommons
//
//  Created by Werner Altewischer on 2/3/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMBlockServiceDelegate.h>
#import <BMCommons/BMWeakReference.h>
#import <BMCommons/BMWeakReferenceRegistry.h>
#import <BMCommons/BMCore.h>
#import <objc/runtime.h>

@interface BMBlockServiceDelegate ()

@property(copy) BMServiceSuccessBlock successBlock;
@property(copy) BMServiceFailureBlock failureBlock;
@property (weak) id<BMService> service;

@end

@implementation BMBlockServiceDelegate {
    id __weak _owner;
}

@synthesize successBlock = _successBlock;
@synthesize failureBlock = _failureBlock;
@synthesize service = _service;

static const char * kBlockDelegatesAssociationKey = "com.behindmedia.bmcommons.BMBlockServiceDelegates";

+ (BMBlockServiceDelegate *)delegateWithSuccess:(BMServiceSuccessBlock)success failure:(BMServiceFailureBlock)failure owner:(id)owner {
    return [[self alloc] initWithSuccess:success failure:failure owner:owner];
}

+ (BMBlockServiceDelegate *)delegateWithSuccess:(BMServiceSuccessBlock)success failure:(BMServiceFailureBlock)failure {
    return [[self alloc] initWithSuccess:success failure:failure];
}

+ (NSMutableArray *)runningServices {
    static NSMutableArray *runningServices = nil;
    BM_DISPATCH_ONCE((^ {
        runningServices = [NSMutableArray new];
    }));
    return runningServices;
}

- (id)init {
    return [self initWithSuccess:nil failure:nil owner:nil];
}

- (id)initWithSuccess:(BMServiceSuccessBlock)success failure:(BMServiceFailureBlock)failure owner:(id)owner {
    if ((self = [super init])) {
        self.successBlock = success;
        self.failureBlock = failure;
        [self setOwner:owner];
    }
    return self;
}

- (id)initWithSuccess:(BMServiceSuccessBlock)success failure:(BMServiceFailureBlock)failure {
    return [self initWithSuccess:success failure:failure owner:nil];
}

- (void)dealloc {
    self.owner = nil;
}

- (void)setOwner:(id)owner {
    @synchronized(self) {
        if (_owner != owner) {
            if (_owner) {
                [[BMWeakReferenceRegistry sharedInstance] deregisterReference:_owner forOwner:self];
                [self setAssociatedWithOwner:NO];
                _owner = nil;
            }
            if (owner) {
                _owner = owner;
                [self setAssociatedWithOwner:YES];
                __typeof(self) __weak weakSelf = self;
                [[BMWeakReferenceRegistry sharedInstance] registerReference:_owner forOwner:self withCleanupBlock:^{
                    [weakSelf.service cancel];
                }];
            }
        }
    }
}

- (id)owner {
    @synchronized (self) {
        return _owner;
    }
}

- (void)setAssociatedWithOwner:(BOOL)associated {
    @synchronized(self) {
        if (_owner) {
            @synchronized(_owner) {
                NSMutableArray *associatedBlockDelegates = objc_getAssociatedObject(_owner, kBlockDelegatesAssociationKey);
                if (associated) {
                    if (associatedBlockDelegates == nil) {
                        associatedBlockDelegates = [NSMutableArray new];
                        objc_setAssociatedObject(_owner, kBlockDelegatesAssociationKey, associatedBlockDelegates, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    }
                    [associatedBlockDelegates addObject:self];
                } else if (associatedBlockDelegates) {
                    [associatedBlockDelegates removeObjectIdenticalTo:self];
                    if (associatedBlockDelegates.count == 0) {
                        objc_setAssociatedObject(_owner, kBlockDelegatesAssociationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    }
                }
            }
        }
    }
}

- (void)service:(id <BMService>)service succeededWithResult:(id)result {
    self.service = nil;
    if (self.successBlock) {
        self.successBlock(result);
    }
    [[self class] popDelegate:self forService:service];
}

- (void)service:(id <BMService>)service failedWithError:(NSError *)error {
    self.service = nil;
    if (self.failureBlock) {
        self.failureBlock(NO, error);
    }
    [[self class] popDelegate:self forService:service];
}

- (void)serviceDidStart:(id<BMService>)service {
    self.service = service;
    [[self class] pushDelegate:self];
}

- (void)serviceWasCancelled:(id<BMService>)service {
    self.service = nil;
    if (self.failureBlock) {
        self.failureBlock(YES, nil);
    }
    [[self class] popDelegate:self forService:service];
}

+ (void)pushDelegate:(BMBlockServiceDelegate *)delegate {
    @synchronized (BMBlockServiceDelegate.class) {
        if (![self.runningServices containsObject:delegate]) {
            [self.runningServices addObject:delegate];
        }
    }
}

+ (void)popDelegate:(BMBlockServiceDelegate *)delegate forService:(id <BMService>)service {
    service.delegate = nil;
    [delegate setAssociatedWithOwner:NO];
    @synchronized (BMBlockServiceDelegate.class) {
        [self.runningServices removeObject:delegate];
    }
}

+ (NSArray *)activeBlockDelegatesForOwner:(id)owner {
    NSArray *currentRunningServices = nil;
    @synchronized(BMBlockServiceDelegate.class) {
        currentRunningServices = [NSArray arrayWithArray:self.runningServices];
    }
    NSMutableArray *ret = [NSMutableArray array];
    for (BMBlockServiceDelegate *d in currentRunningServices) {
        if (owner == nil || d.owner == owner) {
            [ret addObject:d];
        }
    }
    return ret;
}

@end
