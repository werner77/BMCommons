//
//  UINavigationBar+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/9/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "UINavigationBar+BMCommons.h"

@implementation UINavigationBar(BMCommons)

+ (Class)layerClass {
	return [BMNavigationBarLayer class];
}

- (void)bmSetBackgroundView:(UIView *)v {
	if (v) {
		v.frame = self.bounds;
		[(BMNavigationBarLayer *) self.layer bmAddBackgroundLayer:v.layer];
	}
}

@end

@implementation BMNavigationBarLayer 

- (void)insertSublayer:(CALayer *)layer atIndex:(unsigned)idx {
	if ( idx == 0 ) idx = 1;
	[super insertSublayer:layer atIndex:idx];
}

- (void)bmAddBackgroundLayer:(CALayer*)layer {
	[super insertSublayer:layer atIndex:0];
}

@end
