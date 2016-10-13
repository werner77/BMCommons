//
//  BMOverlayImageView.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/21/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMUICore/BMAnimatedImageView.h>

/**
 Image view with support for an overlay view.
 */
@interface BMOverlayImageView : BMAnimatedImageView

@property (nonatomic, strong) UIView *overlayView;

- (void)setImage:(UIImage *)theImage withOverlayView:(UIView *)theOverlayView;

@end
