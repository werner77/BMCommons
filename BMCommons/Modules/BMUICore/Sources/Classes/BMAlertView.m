//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAlertView.h>
#import <BMCommons/BMWeakTimer.h>

@implementation BMAlertView {
    BMWeakTimer *_automaticDismissTimer;
    BOOL _needsConfiguration;
}

- (instancetype)initWithTitle:(NSAttributedString *)title
                      message:(NSAttributedString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
{
    return [self initWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles cancelButtonIndex:0];
}

- (instancetype)initWithTitle:(NSAttributedString *)title
                      message:(NSAttributedString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles
            cancelButtonIndex:(NSInteger)cancelButtonIndex {

    self = [super init];
    if (self)
    {
        self.title = title;
        self.message = message;
        _cancelButtonIndex = -1;

        // construct an array of buttons using the cancel button and other buttons/
        // the following code is a bit ugly and would prefer it in a seperate method, but not possible with var args arguments
        NSMutableArray *buttonTitles = [NSMutableArray array];

        NSInteger index = 0;

        if (cancelButtonIndex < 0) {
            cancelButtonIndex = 0;
        }
        if (cancelButtonIndex > otherButtonTitles.count) {
            cancelButtonIndex = otherButtonTitles.count;
        }

        for (NSString *buttonTitle in otherButtonTitles)
        {
            if (index == cancelButtonIndex && cancelButtonTitle != nil) {
                _cancelButtonIndex = index;
                [buttonTitles addObject:cancelButtonTitle];
            }
            [buttonTitles addObject:buttonTitle];
            index++;
        }

        if (cancelButtonIndex == otherButtonTitles.count && cancelButtonTitle != nil) {
            _cancelButtonIndex = otherButtonTitles.count;
            [buttonTitles addObject:cancelButtonTitle];
        }

        self.buttonTitles = buttonTitles;
    }
    return self;
}

- (void)setAutomaticDismissDelay:(NSTimeInterval)automaticDismissDelay {
    if (automaticDismissDelay != _automaticDismissDelay) {
        [_automaticDismissTimer invalidate];
        _automaticDismissTimer = nil;
        if (automaticDismissDelay > 0) {
            id __weak weakSelf = self;
            _automaticDismissTimer = [BMWeakTimer scheduledTimerWithTimeInterval:automaticDismissDelay block:^(BMWeakTimer *timer) {
                [weakSelf dismiss];
            } repeats:NO];
        }
    }
}

- (id)init
{
    return [self initWithTitle:nil message:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

- (void)dealloc {
}

- (void)dismissWithButtonIndex:(NSInteger)buttonIndex {
    self.automaticDismissDelay = 0;
    if (self.dismissBlock != nil) {
        self.dismissBlock(self, buttonIndex);
    }
}

- (void)dismiss {
    [self dismissWithButtonIndex:self.cancelButtonIndex];
}

- (void)setButtonTitles:(NSArray *)buttonTitles {
    if (buttonTitles != _buttonTitles) {
        _buttonTitles = buttonTitles;
        [self setNeedsConfiguration];
    }

}

- (void)setCancelButtonIndex:(NSInteger)cancelButtonIndex {
    if (_cancelButtonIndex != cancelButtonIndex) {
        _cancelButtonIndex = cancelButtonIndex;
        [self setNeedsConfiguration];
    }
}

- (void)setTitle:(NSAttributedString *)title {
    if (_title != title) {
        _title = title;
        [self setNeedsConfiguration];
    }
}

- (void)setMessage:(NSAttributedString *)message {
    if (_message != message) {
        _message = message;
        [self setNeedsConfiguration];
    }
}

- (void)setNeedsConfiguration {
    _needsConfiguration = YES;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self configureViewIfNeeded];
}

- (void)configureViewIfNeeded {
    if (_needsConfiguration) {
        _needsConfiguration = NO;
        [self configureView];
    }
}

- (void)configureView {

}

@end
