//
//  UITextView+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/15/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "UITextView+BMCommons.h"


@implementation UITextView(BMCommons)

- (void)bmSizeToFitText {
	[self sizeToFit];
	
	CGSize contentSize = self.contentSize;
	
	self.frame = CGRectMake(self.frame.origin.x,
							self.frame.origin.y,
							contentSize.width,
							contentSize.height);
}

@end
