//
//  UIAlertView+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 31/05/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "UIAlertView+BMCommons.h"


@implementation UIAlertView(BMCommons)
static NSMutableDictionary *contextDictionary = nil;
- (void)setBmContext:(id)bmContext {
	if (bmContext) {
		if (contextDictionary == nil) {
			contextDictionary = [NSMutableDictionary new];
		}
		contextDictionary[@((NSInteger)self)] = bmContext;
	} else {
		[contextDictionary removeObjectForKey:@((NSInteger)self)];
	}
}
- (id)bmContext {
	return contextDictionary[@((NSInteger)self)];
}
@end
