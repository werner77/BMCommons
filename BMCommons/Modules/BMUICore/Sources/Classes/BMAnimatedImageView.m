//
//  BMAnimatedImageView.m
//  BMCommons
//
//  Created by Werner Altewischer on 15/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAnimatedImageView.h>
#import <QuartzCore/QuartzCore.h>
#import <BMCommons/BMUICore.h>
#import <BMCommons/BMProxy.h>

@implementation BMAnimatedImageView {
    NSTimer *animationTimer;
}

@synthesize transitionDuration;

- (void)dealloc {
    if (animationTimer) {
        [self stopAnimating];
    }
}

- (void)crossfadeToImage:(UIImage *)newImage {
    CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
    crossFade.duration = (self.transitionDuration > 0.0 ? self.transitionDuration : BM_SLOW_TRANSITION_DURATION);
    crossFade.fromValue = (id)self.image.CGImage;
    crossFade.toValue = (id)newImage.CGImage;
    [self.layer addAnimation:crossFade forKey:@"animateContents"];
    self.image = newImage;
}

- (UIImage *)nextImage {
    NSUInteger index = [self.animationImages indexOfObjectIdenticalTo:self.image];
    
    if (index == NSNotFound || index == (self.animationImages.count - 1)) {
        index = 0;
    } else {
        index++;
    }
    
    UIImage *nextImage = (self.animationImages)[index];
    return nextImage;
}

- (void)crossFadeToNextImage {
    [self crossfadeToImage:self.nextImage];
}

- (void)startAnimating {
    if (!animationTimer && self.animationImages.count > 1) {
        if (!self.image) {
            self.image = (self.animationImages)[0];
        }
        animationTimer = [NSTimer scheduledTimerWithTimeInterval:(self.animationDuration/self.animationImages.count)
                                                          target:[BMProxy proxyWithObject:self threadSafe:NO retained:NO]
                                                        selector:@selector(crossFadeToNextImage) 
                                                        userInfo:nil 
                                                         repeats:YES];
    }
}

- (void)stopAnimating {
    if (animationTimer) {
        [animationTimer invalidate];
        animationTimer = nil;
    }
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

    }
    return self;
}
         
@end
