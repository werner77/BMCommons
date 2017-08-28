//
//  BMMaskView.h
//  BMCommons
//
//  Created by Werner Altewischer on 01/10/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 View for showing an overlay with a specified image.
 */
@interface BMMaskView : UIView

@property (nullable, nonatomic, strong) UIImageView *imageView;

/**
 Hides the view.
 */
- (void)hide;

/**
 Shows the view.
 */
- (void)show;

@end

NS_ASSUME_NONNULL_END
