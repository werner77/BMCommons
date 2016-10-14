//
//  BMAnimatedImageView.h
//  BMCommons
//
//  Created by Werner Altewischer on 15/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Image view with support for crossfade between animationImages.
 */
@interface BMAnimatedImageView : UIImageView 

@property (nonatomic, assign) CGFloat transitionDuration;

/**
 Cross fades to the specified image with the set transitionDuration.
 */
- (void)crossfadeToImage:(UIImage *)newImage;

@end
