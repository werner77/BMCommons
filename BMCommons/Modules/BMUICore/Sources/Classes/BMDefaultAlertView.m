//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <BMCommons/BMDefaultAlertView.h>
#import <BMCommons/BMUICore.h>
#import "NSString+BMUICore.h"

static const CGFloat kBMAlertViewCornerRadius = 7.0f;
static const CGFloat kBMGradientMinimumWhiteValue = 255.0f / 255.0f;
static const CGFloat kBMGradientMaximumWhiteValue = 255.0f / 255.0f;
static const CGFloat kBMButtonHeight = 45.0f;
static const CGFloat kBMSeperatorWhiteValue = 227.0f / 255.0f;
static const CGFloat kBMLabelPadding = 10.0f;
static const CGFloat kBMLabelOriginY = 20.0f;
static const CGFloat kBMBackgroundAlpha = 1.0f;

static void StrokeButtonOutline(CGColorRef lineColor, CGRect btn_frame, NSUInteger btn_count, CGContextRef ctx, BOOL verticalLayout);
static void DrawGradient(CGRect rect, CGContextRef ctx);

@interface BMDefaultAlertButton : UIButton

+ (instancetype)alertViewButtonWithTitle:(NSString *)title boldStyle:(BOOL)bold;

@end


@interface BMDefaultAlertView ()

@property (nonatomic, assign) BOOL layoutButtonsVertically;

@end

@implementation BMDefaultAlertView
{
    NSArray *_buttons;
    UILabel *_titleLabel;
    UILabel *_messageLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.cornerRadius = kBMAlertViewCornerRadius;
        self.layer.masksToBounds = YES;
        self.layoutButtonsVertically = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

#pragma mark - View layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    const CGFloat maxWidth = self.bounds.size.width - (kBMLabelPadding * 2);

    CGFloat y = kBMLabelOriginY;

    CGSize constraint = CGSizeMake(maxWidth, CGFLOAT_MAX);
    if (_titleLabel != nil)
    {
        CGSize textSize = [_titleLabel.text sizeWithFont:_titleLabel.font constrainedToSize:constraint lineBreakMode:_titleLabel.lineBreakMode];
        _titleLabel.frame = BMRectMakeIntegral(kBMLabelPadding, y, maxWidth, textSize.height);
        y += _titleLabel.frame.size.height + kBMLabelPadding;
    }

    if (_messageLabel != nil)
    {
        CGSize textSize = [_messageLabel.text sizeWithFont:_messageLabel.font constrainedToSize:constraint lineBreakMode:_messageLabel.lineBreakMode];
        _messageLabel.frame = BMRectMakeIntegral(kBMLabelPadding, y, maxWidth, textSize.height);
    }

    if (self.layoutButtonsVertically) {
        NSInteger numberOfButtons = _buttons.count;
        CGFloat buttonY = self.bounds.size.height - numberOfButtons * kBMButtonHeight;
        CGFloat buttonX = CGRectGetMinX(self.bounds);
        [self layoutButtonsVerticallyWithOrigin:CGPointMake(buttonX, buttonY) height:kBMButtonHeight width:self.bounds.size.width];
    } else {
        CGFloat buttonY = self.bounds.size.height - kBMButtonHeight;
        CGFloat buttonX = CGRectGetMinX(self.bounds);
        [self layoutButtonsHorizontallyWithOrigin:CGPointMake(buttonX, buttonY) height:kBMButtonHeight width:floorf(self.bounds.size.width/self.buttonTitles.count)];
    }
}

- (NSArray *)buttons {
    return _buttons;
}

- (void)layoutButtonsHorizontallyWithOrigin:(CGPoint)origin height:(CGFloat)height width:(CGFloat)width
{
    if (self.buttonTitles.count > 0)
    {
        [[self buttons] enumerateObjectsUsingBlock:^ (UIButton *button, NSUInteger idx, BOOL *stop) {
            button.frame = CGRectMake(origin.x + idx * width, origin.y, width, height);
        }];
    }
}

- (void)layoutButtonsVerticallyWithOrigin:(CGPoint)origin height:(CGFloat)height width:(CGFloat)width
{
    if (self.buttonTitles.count > 0)
    {
        [[self buttons] enumerateObjectsUsingBlock:^ (UIButton *button, NSUInteger idx, BOOL *stop) {
            button.frame = CGRectMake(origin.x, origin.y + idx * height, width, height);
        }];
    }
}


- (CGSize)sizeThatFits:(CGSize)size
{
    const CGFloat width = MIN(size.width, 270);

    CGFloat height = kBMLabelOriginY;

    if (self.title.length > 0)
    {
        CGFloat maxWidth = width - (kBMLabelPadding * 2);
        CGSize textSize = [_titleLabel.text bmSizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:_titleLabel.lineBreakMode];
        height += textSize.height + kBMLabelPadding;
    }

    if (self.message.length > 0)
    {
        CGFloat maxWidth = width - (kBMLabelPadding * 2);
        CGSize textSize = [_messageLabel.text bmSizeWithFont:_messageLabel.font constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:_messageLabel.lineBreakMode];
        height += textSize.height + kBMLabelOriginY;
    }

    if (self.layoutButtonsVertically) {
        for (int i = 0; i < self.buttonTitles.count; ++i) {
            height += kBMButtonHeight;
        }
    } else {
        if (self.buttonTitles.count > 0)
        {
            height += kBMButtonHeight;
        }
    }

    return CGSizeMake(ceilf(width), ceilf(height));
}

#pragma mark - Public properties

- (void)configureView {

    if (self.title.length == 0)
    {
        [_titleLabel removeFromSuperview];
    } else {
        if (!_titleLabel)
        {
            _titleLabel = [UILabel new];
            _titleLabel.numberOfLines = 0;
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self addSubview:_titleLabel];
        }
        _titleLabel.attributedText = self.title;
    }

    if (self.message.length == 0)
    {
        [_messageLabel removeFromSuperview];
    } else {
        if (!_messageLabel)
        {
            _messageLabel = [UILabel new];
            _messageLabel.numberOfLines = 0;
            _messageLabel.textAlignment = NSTextAlignmentCenter;
            _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self addSubview:_messageLabel];
        }
        _messageLabel.attributedText = self.message;
    }

    for (UIButton *button in _buttons)
    {
        [button removeFromSuperview];
    }

    if (self.buttonTitles.count > 0)
    {
        NSMutableArray *buttons = [NSMutableArray array];

        __block NSInteger maxLength = 0;

        [self.buttonTitles enumerateObjectsUsingBlock:^ (NSString *title, NSUInteger idx, BOOL *stop) {
            BOOL bold = (idx == self.cancelButtonIndex);
            UIButton *button = [self alertViewButtonWithTitle:title bold:bold];

            maxLength = title.length;

            button.tag = idx;
            [button addTarget:self action:@selector(handleButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [buttons addObject:button];
            [self addSubview:button];
        }];
        self.layoutButtonsVertically = maxLength > 10 || self.buttonTitles.count > 2;

        _buttons = buttons;
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    const CGFloat width = self.bounds.size.width;

    DrawGradient(rect, ctx);

    // draw button outline
    CGFloat outline_y;
    if (self.layoutButtonsVertically) {
        outline_y = self.bounds.size.height - _buttons.count * kBMButtonHeight;
    } else {
        outline_y = self.bounds.size.height - kBMButtonHeight;
    }

    CGFloat height = self.bounds.size.height - outline_y;
    CGRect outline_frame = CGRectMake(0, outline_y, width, height);
    CGColorRef lineColor = [UIColor colorWithWhite:kBMSeperatorWhiteValue alpha:1.0f].CGColor;
    StrokeButtonOutline(lineColor, outline_frame, self.buttonTitles.count, ctx, self.layoutButtonsVertically);
}

#pragma mark - Private

- (void)handleButtonTouchUpInside:(UIButton *)sender
{
    [self dismissWithButtonIndex:sender.tag];
}

- (UIButton *)alertViewButtonWithTitle:(NSString *)title bold:(BOOL)bold
{
    return [BMDefaultAlertButton alertViewButtonWithTitle:title boldStyle:bold];
}


#pragma mark - Custom drawing

static void DrawGradient(CGRect rect, CGContextRef ctx)
{
    // the colors
    CGColorRef color1 = [UIColor colorWithWhite:kBMGradientMinimumWhiteValue alpha:kBMBackgroundAlpha].CGColor;
    CGColorRef color2 = [UIColor colorWithWhite:kBMGradientMaximumWhiteValue alpha:kBMBackgroundAlpha].CGColor;
    CGColorRef color3 = [UIColor colorWithWhite:kBMGradientMinimumWhiteValue alpha:kBMBackgroundAlpha].CGColor;
    NSArray *colors = @[(__bridge id) color1, (__bridge id) color2, (__bridge id) color3];
    CGFloat locations[] = {0, 0.5f, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(CGColorGetColorSpace(color1), (__bridge CFArrayRef)colors, locations);

    // the start/end points
    CGRect bounds = rect;
    CGPoint top = CGPointMake(CGRectGetMidX(bounds), bounds.origin.y);
    CGPoint bottom = CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(bounds));

    // draw
    CGContextDrawLinearGradient(ctx, gradient, top, bottom, 0);

    CGGradientRelease(gradient);
}

static void StrokeButtonOutline(CGColorRef lineColor, CGRect btn_frame, NSUInteger btn_count, CGContextRef ctx, BOOL verticalLayout)
{
    if (btn_count > 0)
    {
        // configure stroke drawing
        CGContextSetLineWidth(ctx, 0.4f);
        CGContextSetShouldAntialias(ctx, false);
        CGContextSetStrokeColorWithColor(ctx, lineColor);

        // first draw the horizontal (top) seperator
        CGContextMoveToPoint(ctx, btn_frame.origin.x, btn_frame.origin.y);
        CGContextAddLineToPoint(ctx, btn_frame.origin.x + btn_frame.size.width, btn_frame.origin.y);
        CGContextStrokePath(ctx);
    }

    if (verticalLayout) {
        for (int i = 1; i < btn_count; ++i) {
            CGFloat y = btn_frame.origin.y + i * kBMButtonHeight;
            CGContextMoveToPoint(ctx, btn_frame.origin.x, y);
            CGContextAddLineToPoint(ctx, btn_frame.origin.x + btn_frame.size.width, y);
            CGContextStrokePath(ctx);
        }
    } else {
        CGFloat btn_width = floorf(btn_frame.size.width / btn_count);
        for (int i = 1; i < btn_count; ++i) {
            CGFloat y = btn_frame.origin.y;
            CGFloat x = btn_frame.origin.x + i * btn_width;
            CGContextMoveToPoint(ctx, x, y);
            CGContextAddLineToPoint(ctx, x, y + btn_frame.size.height);
            CGContextStrokePath(ctx);
        }
    }
}

@end

@implementation BMDefaultAlertButton


+ (instancetype)alertViewButtonWithTitle:(NSString *)title boldStyle:(BOOL)bold
{
    BMDefaultAlertButton *button = [BMDefaultAlertButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:125.0f/255.0f blue:255.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    CGFloat fontSize = [UIFont labelFontSize];
    UIFont *font = bold ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
    [button.titleLabel setFont:font];
    return button;
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (self.tracking && self.touchInside)
    {
        self.backgroundColor = highlighted ? [UIColor colorWithWhite:0.0f alpha:0.05f] : [UIColor clearColor];
    }
    else
    {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
