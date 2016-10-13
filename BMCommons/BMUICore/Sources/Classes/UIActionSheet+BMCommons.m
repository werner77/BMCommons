//
//  UIActionSheet+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 13/09/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "UIActionSheet+BMCommons.h"

@implementation UIActionSheet(BMCommons)

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
