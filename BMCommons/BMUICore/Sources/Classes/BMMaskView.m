//
//  BMMaskView.m
//  BMCommons
//
//  Created by Werner Altewischer on 01/10/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMMaskView.h"
#import <BMUICore/BMUICore.h>
#import <BMUICore/UIScreen+BMCommons.h>

@implementation BMMaskView {
	UIImageView *imageView;
}

@synthesize imageView;

- (id)init {
	if ((self = [self initWithFrame:[[UIScreen mainScreen] bmPortraitBounds]])) {
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
        BMUICoreCheckLicense();
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
		[self hide];
	}
	return self;
}

- (void)dealloc {
	[self.imageView removeFromSuperview];
}

- (void)hide {
	if (self.imageView) {
		[self.imageView removeFromSuperview];
	} else {
		self.alpha = 0.0;
	}
}

- (void)show {
	if (self.imageView) {
		[self addSubview:self.imageView];
	} else {
		self.alpha = 1.0;
	}
}

@end
