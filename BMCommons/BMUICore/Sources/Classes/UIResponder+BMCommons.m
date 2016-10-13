//
//  UIResponder+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 1/11/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "UIResponder+BMCommons.h"
#import <BMCore/BMCore.h>

NSString *const BMResponderDidBecomeFirstNotification = @"BMResponderDidBecomeFirstNotification";
NSString *const BMResponderDidResignFirstNotification = @"BMResponderDidResignFirstNotification";

@implementation UIResponder(BMCommons)

static IMP resignFirstResponderImp = NULL;
static IMP becomeFirstResponderImp = NULL;

static BOOL BMBecomeFirstResponder(id self, SEL cmd) {
	BOOL ret = ((BOOL (*)(id, SEL))becomeFirstResponderImp)(self, cmd);
	if (ret) {
		[self bmPostDidBecomeFirstResponderNotification];
	}
	return ret;
}

static BOOL BMResignFirstResponder(id self, SEL cmd) {
	BOOL ret = ((BOOL (*)(id, SEL))resignFirstResponderImp)(self, cmd);
	if (ret) {
		[self bmPostDidResignFirstResponderNotification];
	}
	return ret;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		becomeFirstResponderImp = BMReplaceMethodImplementation([UIResponder class], @selector(becomeFirstResponder), (IMP)BMBecomeFirstResponder);
		resignFirstResponderImp = BMReplaceMethodImplementation([UIResponder class], @selector(resignFirstResponder), (IMP)BMResignFirstResponder);
	});
}

- (void)bmPostDidBecomeFirstResponderNotification {
	NSNotification *notification = [NSNotification notificationWithName:BMResponderDidBecomeFirstNotification object:self];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)bmPostDidResignFirstResponderNotification {
	NSNotification *notification = [NSNotification notificationWithName:BMResponderDidResignFirstNotification object:self];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
