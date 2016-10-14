//
//  UITextView+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/15/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UITextView additions.
 */
@interface UITextView(BMCommons)

/**
 Calls sizeToFit and adjusts the frame to the content size.
 */
- (void)bmSizeToFitText;

@end
