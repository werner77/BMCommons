//
//  BMTimer.m
//  BMCommons
//
//  Created by Werner Altewischer on 4/3/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMWeakTimer.h>
#import <BMCommons/BMCore.h>
#import <BMCommons/BMVersionAvailability.h>
#import <BMCommons/NSInvocation+BMCommons.h>
#import <CoreFoundation/CoreFoundation.h>

@interface BMWeakTimer()

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) NSInvocation *invocation;
@property (nonatomic, strong, readonly) NSTimer *timerImpl;
@property (nonatomic, copy) BMWeakTimerBlock block;

@end

@interface BMTimerUserInfo : NSObject

@property (nonatomic, weak) BMWeakTimer *timer;

@end

@implementation BMTimerUserInfo

@end

@implementation BMWeakTimer

+ (BMWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    return [self scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo onRunloop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

+ (BMWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo onRunloop:(NSRunLoop *)runloop forMode:(NSString *)mode {
    BMWeakTimer *timer = [self timerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    [timer scheduleOnRunloop:runloop forMode:mode];
    return timer;
}

+ (BMWeakTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    BMWeakTimer *timer = [[self alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:ti] interval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    return timer;
}

+ (BMWeakTimer *)timerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo {
    BMWeakTimer *timer = [[self alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:ti] interval:ti invocation:invocation repeats:yesOrNo];
    return timer;
}

+ (BMWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo {
    BMWeakTimer *timer = [self scheduledTimerWithTimeInterval:ti invocation:invocation repeats:yesOrNo onRunloop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    return timer;
}

+ (BMWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo
                                      onRunloop:(NSRunLoop *)runloop forMode:(NSString *)mode {
    BMWeakTimer *timer = [self timerWithTimeInterval:ti invocation:invocation repeats:yesOrNo];
    [timer scheduleOnRunloop:runloop forMode:mode];
    return timer;
}

+ (BMWeakTimer *)timerWithTimeInterval:(NSTimeInterval)ti block:(BMWeakTimerBlock)block repeats:(BOOL)yesOrNo {
    BMWeakTimer *timer = [[self alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:ti] interval:ti block:block repeats:yesOrNo];
    return timer;
}

+ (BMWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(BMWeakTimerBlock)block repeats:(BOOL)yesOrNo {
    return [self scheduledTimerWithTimeInterval:ti block:block repeats:yesOrNo onRunloop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

+ (BMWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(BMWeakTimerBlock)block repeats:(BOOL)yesOrNo
                                      onRunloop:(NSRunLoop *)runloop forMode:(NSString *)mode {
    BMWeakTimer *timer = [self timerWithTimeInterval:ti block:block repeats:yesOrNo];
    [timer scheduleOnRunloop:runloop forMode:mode];
    return timer;
}


- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep {
    if ((self = [super init])) {
        
        BMTimerUserInfo *userInfo = [BMTimerUserInfo new];
        userInfo.timer = self;

        self.userInfo = ui;
        self.target = t;
        self.selector = s;
        
        _timerImpl = [[NSTimer alloc] initWithFireDate:date interval:ti target:[self class] selector:@selector(fireTimer:) userInfo:userInfo repeats:rep];
    }
    return self;
}

                          
- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)rep {
    if ((self = [super init])) {
        
        BMTimerUserInfo *userInfo = [BMTimerUserInfo new];
        userInfo.timer = self;
        
        self.target = invocation.target;
        invocation.target = nil;
        [invocation retainArguments];
        self.invocation = invocation;
        
        _timerImpl = [[NSTimer alloc] initWithFireDate:date interval:ti target:[self class] selector:@selector(fireTimer:) userInfo:userInfo repeats:rep];
    }
    return self;
}

- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti block:(BMWeakTimerBlock)block repeats:(BOOL)rep {
    if ((self = [super init])) {
        
        BMTimerUserInfo *userInfo = [BMTimerUserInfo new];
        userInfo.timer = self;
        
        self.target = nil;
        self.selector = NULL;
        self.block = block;
        
        _timerImpl = [[NSTimer alloc] initWithFireDate:date interval:ti target:[self class] selector:@selector(fireTimer:) userInfo:userInfo repeats:rep];
    }
    return self;
}

- (void)dealloc {
    [self invalidate];
}

+ (void)fireTimer:(NSTimer *)timer {
    BMTimerUserInfo *userInfo = timer.userInfo;
    BMWeakTimer *bmTimer = userInfo.timer;
    
    if (bmTimer) {
        [bmTimer fire];
    } else {
        LogWarn(@"Timer fired but target not available anymore: invalidating timer");
        [timer invalidate];
    }
}

- (void)scheduleOnRunloop:(NSRunLoop *)runloop forMode:(NSString *)mode {
    if (self.timerImpl) {
        [runloop addTimer:self.timerImpl forMode:mode];
    }
}

- (void)fire {
    if (self.target) {
        if (self.invocation) {
            [self.invocation invokeWithTarget:self.target];
        } else if (self.selector) {
            BM_IGNORE_SELECTOR_LEAK_WARNING(
                    [self.target performSelector:self.selector withObject:self];
            )
        }
    } else if (self.block) {
        self.block(self);
    }
}

- (NSDate *)fireDate {
    return self.timerImpl.fireDate;
}

- (void)setFireDate:(NSDate *)date {
    self.timerImpl.fireDate = date;
}

- (NSTimeInterval)timeInterval {
    return self.timerImpl.timeInterval;
}

- (NSTimeInterval)tolerance {
    return self.timerImpl.tolerance;
}

- (void)setTolerance:(NSTimeInterval)tolerance {
    [self.timerImpl setTolerance:tolerance];
}

- (void)invalidate {
    [self.timerImpl invalidate];
    _timerImpl = nil;
}

- (BOOL)isValid {
    return self.timerImpl != nil && self.timerImpl.isValid;
}

@end
