//
//  BMBarButtonItem.m
//  BMCommons
//
//  Created by Werner Altewischer on 01/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMBarButtonItem.h"
#import "UIButton+BMCommons.h"
#import <BMCommons/BMImageHelper.h>

static const CGFloat kMinWidth = 25.0;

@implementation BMBarButtonItem {
    UIInterfaceOrientation orientation;
}

+ (CGRect)frameOfItem:(UIBarButtonItem *)item inView:(UIView *)v {
	
	UIView *theView = item.customView;
	if (!theView.superview && [item respondsToSelector:@selector(view)]) {
		theView = [item performSelector:@selector(view)];
	}
	
	UIView *parentView = theView.superview;
	NSArray *subviews = parentView.subviews;
	
	NSUInteger indexOfView = [subviews indexOfObject:theView];
	NSUInteger subviewCount = subviews.count;
	
	if (subviewCount > 0 && indexOfView != NSNotFound) {
		UIView *button = (parentView.subviews)[indexOfView];
		return [button convertRect:button.bounds toView:v];
	} else {
		return CGRectZero;
	}
}

+ (BMBarButtonItem *)barButtonItemWithImage:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)action {
    return [[BMBarButtonItem alloc] initWithImage:image title:title target:target action:action];
}

- (id)initWithImage:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)action {
    UIImage *bgImage = [UIImage imageNamed:@"BMUICore.bundle/bar-button-item-background.png"];
    UIImage *highlightedBgImage = [UIImage imageNamed:@"BMUICore.bundle/bar-button-item-background-highlighted.png"];
    return [self initWithImage:image backgroundImage:bgImage highlightedBackgroundImage:highlightedBgImage title:title target:target action:action];
}

- (id)initWithTitle:(NSString *)title backgroundImage:(UIImage *)bgImage target:(id)target action:(SEL)action {
    return [self initWithTitle:title backgroundImage:bgImage highlightedBackgroundImage:nil target:target action:action];
}

- (id)initWithImage:(UIImage *)image backgroundImage:(UIImage *)bgImage title:(NSString *)title target:(id)target action:(SEL)action {
    return [self initWithImage:image backgroundImage:bgImage highlightedBackgroundImage:nil title:title target:target action:action];
}

- (id)initWithTitle:(NSString *)title backgroundImage:(UIImage *)bgImage highlightedBackgroundImage:(UIImage *)highlightedBgImage target:(id)target action:(SEL)action {
    return [self initWithImage:nil backgroundImage:bgImage highlightedBackgroundImage:highlightedBgImage title:title target:target action:action];
}

- (id)initWithImage:(UIImage *)image backgroundImage:(UIImage *)bgImage highlightedBackgroundImage:(UIImage *)highlightedBgImage title:(NSString *)title target:(id)target action:(SEL)action {
    
    UIButton *barButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIFont *font = [UIFont boldSystemFontOfSize:13];
    barButton.titleLabel.font = font;
    barButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    if (image) {
        barButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 10);
        barButton.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        barButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [barButton setImage:image forState:UIControlStateNormal];
    }
    [barButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [barButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [barButton setTitleShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [barButton setAdjustsImageWhenHighlighted:NO];
    
    bgImage = [bgImage stretchableImageWithLeftCapWidth:(int)(bgImage.size.width/2) topCapHeight:0];
    [barButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    if (highlightedBgImage) {
        highlightedBgImage = [highlightedBgImage stretchableImageWithLeftCapWidth:(int)(highlightedBgImage.size.width/2) topCapHeight:0];
        [barButton setBackgroundImage:highlightedBgImage forState:UIControlStateHighlighted];
    }
    if ((self = [super initWithCustomView:barButton])) {
        BMUICoreCheckLicense();
        orientation = UIInterfaceOrientationPortrait;
        self.target = target;
        self.action = action;
        [barButton bmSetTarget:target action:action];
        [self setTitle:title];
    }
    return self;
}


- (UIButton *)button {
    UIView *v = self.customView;
    if ([v isKindOfClass:[UIButton class]]) {
        return (UIButton *)v;
    } else {
        return nil;
    }
}

- (void)setOrientation:(UIInterfaceOrientation)theOrientation {
    if (orientation != theOrientation) {
        orientation = theOrientation;
        [self updateFrame];
    }
}

- (UIInterfaceOrientation)orientation {
    return orientation;
}

- (void)updateFrame {
    UIButton *button = self.button;
    UIImage *image = [button imageForState:UIControlStateNormal];
    NSString *title = [button titleForState:UIControlStateNormal];
    
    CGFloat width = image.size.width + 25 + [title sizeWithFont:button.titleLabel.font].width;
    width = MAX(kMinWidth, width);
    CGFloat height = UIInterfaceOrientationIsPortrait(self.orientation) ? 30 : 24;
    button.frame = CGRectMake(0, 0, width, height);
}

- (void)setTitle:(NSString *)title {
    UIButton *button = self.button;
    [button setTitle:title forState:UIControlStateNormal];
    [self updateFrame];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self.button setEnabled:enabled];
}

@end


