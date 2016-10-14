//
//  BMFlashButton.m
//  BMCommons
//
//  Created by Werner Altewischer on 17/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMFlashButton.h>
#import <BMCommons/BMEnumeratedValue.h>
#import <BMMedia/BMMedia.h>
#import <BMCommons/BMCore.h>
#import <BMCommons/BMProxy.h>

#define TEXT_MARGIN 10.0
#define MIN_LABEL_WIDTH 50.0
#define MIN_LAST_LABEL_WIDTH 45.0

#define BASE_MULTIPLIER 10
#define LABEL_MULTIPLIER 100

@interface BMFlashButton(Private)

- (NSString *)selectedTitle;
- (UIImageView *)imageViewWithImage:(UIImage *)image;
- (UILabel *)labelForText:(NSString *)text andIndex:(NSUInteger)index;
- (CGFloat)addButtonAtPoint:(CGPoint)point withTitle:(NSString *)text andIndex:(NSUInteger)index addAsSubview:(BOOL)addAsSubview;
- (void)startAutoCollapseTimer;
- (void)stopAutoCollapseTimer;
- (void)updateButtons;
- (void)setExpanded:(BOOL)b animated:(BOOL)animated;

@end

@implementation BMFlashButton {
    UIImage *leftImage;
    UIImage *rightImage;
    UIImage *middleImage;
    UIImage *borderImage;
    
    NSUInteger selectedIndex;
    NSArray *items;
    
    NSMutableArray *buttonSeparatorLocations;
    
    BOOL expanded;
    NSTimer *timer;
}

const NSTimeInterval BMFlashButtonExpandAnimationDuration = 0.2;

@synthesize items, selectedIndex, expanded;

- (void)dealloc {
    if (timer) {
        [self stopAutoCollapseTimer];
    }
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {

        leftImage = [UIImage imageNamed:@"BMMedia.bundle/PLCameraFlashBackgroundLeft.png"];
        middleImage = [UIImage imageNamed:@"BMMedia.bundle/PLCameraFlashBackgroundMiddle.png"];
        borderImage = [UIImage imageNamed:@"BMMedia.bundle/PLCameraFlashBackgroundBorder.png"];
        
        UIImage *theImage = [UIImage imageNamed:@"BMMedia.bundle/PLCameraFlashBackgroundRight.png"];
        
        rightImage = theImage;
        self.backgroundColor = [UIColor clearColor];
        buttonSeparatorLocations = [NSMutableArray new];
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:gr];
    }
    return self;
}

- (void)setItems:(NSArray *)theItems {
    if (theItems != items) {
        BOOL animated = (items != nil && self.leftImageView != nil);
        items = theItems;
        //To force set expanded to NO
        if (expanded) {
            [self setExpanded:NO animated:animated];
        } else {
            [self updateButtons];
        }
    }
}

- (BMEnumeratedValue *)selectedItem {
    return selectedIndex < items.count ? items[selectedIndex] : nil;
}

- (UIImageView *)leftImageView {
    return (UIImageView *)[self viewWithTag:BASE_MULTIPLIER * 1];
}

- (UIImageView *)rightImageView {
    return (UIImageView *)[self viewWithTag:BASE_MULTIPLIER * 2];
}

- (UILabel *)firstLabel {
    return (UILabel *)[self viewWithTag:LABEL_MULTIPLIER * 1];
}

- (void)layoutSubviews {
    
    if (!self.leftImageView) {
        [self updateButtons];
    }
    
    int x = CGRectGetMinX(self.rightImageView.frame);
    
    CGAffineTransform inverseTransform = CGAffineTransformInvert(self.transform);
    
    CGPoint normalizedCenter = CGPointApplyAffineTransform(self.center, inverseTransform);
    
    normalizedCenter = CGPointMake(normalizedCenter.x + (x - self.bounds.size.width)/2, normalizedCenter.y);
    
    normalizedCenter = CGPointApplyAffineTransform(normalizedCenter, self.transform);
    
    self.bounds = CGRectMake(0, 0, x, self.bounds.size.height);
    
    self.center = CGPointMake((int)normalizedCenter.x, (int)normalizedCenter.y);
    
    [super layoutSubviews];
}

- (void)setHidden:(BOOL)hidden {
    
    if (hidden) {
        [self setExpanded:NO animated:NO];
    }
    
    [super setHidden:hidden];
}

@end

@implementation BMFlashButton(Private)

- (UIImageView *)imageViewWithImage:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.autoresizingMask = UIViewAutoresizingNone;
    imageView.clipsToBounds = NO;
    return imageView;
}

- (UILabel *)labelForText:(NSString *)text andIndex:(NSUInteger)index {
    
    UILabel *label = [[UILabel alloc] init];
    
    label.tag = LABEL_MULTIPLIER * (index + 1);
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.contentMode = UIViewContentModeCenter;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    label.font = [UIFont boldSystemFontOfSize:17.0];
    
    [label sizeToFit];
    
    CGFloat minLabelWidth = (index == items.count - 1) ? MIN_LAST_LABEL_WIDTH : MIN_LABEL_WIDTH;
    
    if (label.frame.size.width < minLabelWidth && index > 0 && index <= items.count - 1) {
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, minLabelWidth, label.frame.size.height);
    }
    return label;
}

- (CGFloat)addButtonAtPoint:(CGPoint)point withTitle:(NSString *)text andIndex:(NSUInteger)index addAsSubview:(BOOL)addAsSubview {
    
    CGFloat x = point.x;
    CGFloat y = point.y;
    
    BOOL isLast = (index == items.count - 1);
    
    UILabel *label = [self labelForText:text andIndex:index];
    
    label.frame = CGRectMake(x, y, label.frame.size.width + 2 * TEXT_MARGIN, middleImage.size.height/2);
    
    UIImage *image = [middleImage stretchableImageWithLeftCapWidth:0 topCapHeight:(int)(middleImage.size.height/2)];
    
    UIImageView *middleImageView = [self imageViewWithImage:image];
    
    CGFloat frameWidthOffset = 0.0;
    if (isLast) {
        frameWidthOffset = -10.0;
    }
    
    middleImageView.frame = CGRectMake(x, y, (int)(label.frame.size.width + frameWidthOffset), (int)(middleImage.size.height/2));
    
    if (addAsSubview) {
        [self addSubview:middleImageView];
        [self addSubview:label];
    }
    
    return middleImageView.frame.size.width;
}

- (NSString *)selectedTitle {
    return self.selectedItem.label;
}

- (NSUInteger)indexForLocation:(CGPoint)location {
    NSUInteger index = 0;
    for (NSNumber *n in buttonSeparatorLocations) {
        CGFloat x = [n floatValue];
        
        if (location.x <= x) {
            break;
        }
        index++;
    }
    return index;
}

- (void)startAutoCollapseTimer {
    if (timer) {
        [self stopAutoCollapseTimer];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                             target:[BMProxy proxyWithObject:self threadSafe:NO retained:NO]
                                           selector:@selector(collapse)
                                           userInfo:nil
                                            repeats:NO];
}

- (void)stopAutoCollapseTimer {
    [timer invalidate];
    timer = nil;
}

- (void)setExpanded:(BOOL)b animated:(BOOL)animated {
    if (expanded != b) {
        if (!b) {
            [self stopAutoCollapseTimer];
        } else if (!self.hidden) {
            [self startAutoCollapseTimer];
        }
        expanded = b;
        
        if (animated) {
            UIImageView *leftImageView = [self leftImageView];
            UIImageView *rightImageView = [self rightImageView];
            UILabel *firstLabel = [self firstLabel];
            
            for (UIView *v in self.subviews) {
                if (v != leftImageView && v != rightImageView && v != firstLabel) {
                    [v removeFromSuperview];
                }
            }
            
            int y = CGRectGetMinY(leftImageView.frame);
            int x = CGRectGetMaxX(leftImageView.frame);
            
            NSUInteger numberOfButtons = items.count;
            
            int width = 0;
            if (expanded) {
                for (NSUInteger i = 0; i < numberOfButtons; ++i) {
                    
                    if (i > 0) {
                        //Add separator
                        width += borderImage.size.width;
                    }
                    
                    BMEnumeratedValue *value = items[i];
                    NSString *text = value.label;
                    width += [self addButtonAtPoint:CGPointMake(x, y) withTitle:text andIndex:i addAsSubview:NO];
                }
            } else {
                NSString *selectedText = [self selectedTitle];
                width += [self addButtonAtPoint:CGPointMake(x, y) withTitle:selectedText andIndex:0 addAsSubview:NO];
            }
            
            UIImage *image = [middleImage stretchableImageWithLeftCapWidth:0 topCapHeight:(int)(middleImage.size.height/2)];
            UIImageView *middleImageView = [self imageViewWithImage:image];
            
            middleImageView.frame = CGRectMake(x, y, CGRectGetMinX(rightImageView.frame) - x, CGRectGetHeight(leftImageView.frame));
            
            [self addSubview:middleImageView];
            
            [UIView animateWithDuration:BMFlashButtonExpandAnimationDuration animations:^{
                
                middleImageView.frame = CGRectMake(x, y, width, CGRectGetHeight(leftImageView.frame));
                leftImageView.frame = CGRectMake(CGRectGetMinX(leftImageView.frame), CGRectGetMinY(leftImageView.frame), CGRectGetWidth(leftImageView.frame), CGRectGetHeight(leftImageView.frame));
                rightImageView.frame = CGRectMake(x + width, y, (int)(rightImage.size.width/2), (int)(rightImage.size.height/2));
                
            } completion:^(BOOL finished) {
                [middleImageView removeFromSuperview];
                [self updateButtons];
            }];
        
        } else {
            [self updateButtons];
        }
        
        if (expanded) {
            [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
        } else {
            [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
        }
    }
}

- (void)collapse {
    [self setExpanded:NO animated:YES];
}

- (void)onTap:(UITapGestureRecognizer *)gr {
    CGPoint location = [gr locationInView:self];
    NSUInteger index = [self indexForLocation:location];
    
    if (index == 0 && !expanded) {
        if (items.count > 2) {
            //expand
            [self setExpanded:YES animated:YES];
        } else if (items.count == 2) {
            self.selectedIndex = (selectedIndex == 0 ? 1 : 0);
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            //[self setNeedsLayout];
        }
    } else if (expanded) {
        self.selectedIndex = index;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self setExpanded:NO animated:YES];
    }
}

- (void)updateButtons {
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    
    [buttonSeparatorLocations removeAllObjects];
    
    NSUInteger numberOfButtons = items.count;
    
    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:leftImage];
    leftImageView.tag = 1 * BASE_MULTIPLIER;
    UIImageView *rightImageView = [[UIImageView alloc] initWithImage:rightImage];
    rightImageView.tag = 2 * BASE_MULTIPLIER;
    
    int y = (self.bounds.size.height - leftImage.size.height/2.0)/2.0;
    if (y < 0) {
        y = 0;
    }
    
    int x = 0;
    
    leftImageView.frame = CGRectMake(x, y, (int)leftImage.size.width/2, (int)leftImage.size.height/2);
    
    x += leftImageView.frame.size.width;
    
    if (expanded) {
        for (NSUInteger i = 0; i < numberOfButtons; ++i) {
            
            if (i > 0) {
                //Add separator
                [buttonSeparatorLocations addObject:[NSNumber numberWithFloat:(float)x]];
                UIImageView *separatorView = [self imageViewWithImage:borderImage];
                separatorView.frame = CGRectMake(x, y, (int)(borderImage.size.width/2), (int)(borderImage.size.height/2));
                [self addSubview:separatorView];
                x += separatorView.frame.size.width;
            }
            
            BMEnumeratedValue *value = items[i];
            NSString *text = value.label;
            x += [self addButtonAtPoint:CGPointMake(x, y) withTitle:text andIndex:i addAsSubview:YES];
        }
    } else {
        NSString *text = [self selectedTitle];
        x += [self addButtonAtPoint:CGPointMake(x, y) withTitle:text andIndex:0 addAsSubview:YES];
    }
    
    rightImageView.frame = CGRectMake(x, y, (int)(rightImage.size.width/2), (int)(rightImage.size.height/2));
    
    [self addSubview:leftImageView];
    [self addSubview:rightImageView];
    
}

@end
