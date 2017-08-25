//
//  BMTimer.h
//  BMCommons
//
//  Created by Werner Altewischer on 4/3/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreObject.h>

@class BMWeakTimer;

NS_ASSUME_NONNULL_BEGIN

typedef void(^BMWeakTimerBlock)(BMWeakTimer *timer);

/**
 Timer class that mirrors NSTimer, but that does not retain its target.
 
 See NSTimer reference for documentation, class behaves identical to NSTimer with the only exception of not retaining its target.
 */
@interface BMWeakTimer : BMCoreObject

+ (BMWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

+ (BMWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo onRunloop:(NSRunLoop *)runloop forMode:(NSString *)mode;

+ (BMWeakTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

+ (BMWeakTimer *)timerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo;

+ (BMWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo;

+ (BMWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo
                                      onRunloop:(NSRunLoop *)runloop forMode:(NSString *)mode;

+ (BMWeakTimer *)timerWithTimeInterval:(NSTimeInterval)ti block:(BMWeakTimerBlock)block repeats:(BOOL)yesOrNo;

+ (BMWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(BMWeakTimerBlock)block repeats:(BOOL)yesOrNo;

+ (BMWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti block:(BMWeakTimerBlock)block repeats:(BOOL)yesOrNo
                                      onRunloop:(NSRunLoop *)runloop forMode:(NSString *)mode;


/**
 Constructor of Timer with target/selector.
 */
- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(nullable id)ui repeats:(BOOL)rep;

/**
 Constructor of timer with block for execution.
 */
- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti block:(BMWeakTimerBlock)block repeats:(BOOL)rep;

/**
 Constructor of Timer with an invocation.
 
 The invocation is instructed to retain its arguments but not the target: target of the invocation is set to nil and a weak reference to the target is maintained separately.
 */
- (id)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)rep;

- (void)scheduleOnRunloop:(NSRunLoop *)runloop forMode:(NSString *)mode;

- (void)fire;

- (NSDate *)fireDate;
- (void)setFireDate:(NSDate *)date;

- (NSTimeInterval)timeInterval;

#if TARGET_OS_IPHONE
- (NSTimeInterval)tolerance;
- (void)setTolerance:(NSTimeInterval)tolerance;
#endif

- (void)invalidate;
- (BOOL)isValid;

@property (nullable, nonatomic, strong) id userInfo;

@end

NS_ASSUME_NONNULL_END
