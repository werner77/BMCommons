//
//  BMTextualAlertView.m
//  BMCommons
//
//  Created by Werner Altewischer.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMTextualAlertView.h>
#import <BMCommons/BMDialogHelper.h>
#import <BMCommons/BMStringHelper.h>

@interface BMTextualAlertView()<UIAlertViewDelegate, UITextFieldDelegate>

@end

@interface BMTextualAlertView(Private)

- (void)moveAlert:(BOOL)animated;

@end


@implementation BMTextualAlertView {
	UITextField *textField;
    BOOL valueRequired;
    BOOL first;
    NSString *defaultText;
}

@synthesize textField, valueRequired, defaultText;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        textField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
        [textField setBackgroundColor:[UIColor whiteColor]];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeAlphabet;
        textField.keyboardAppearance = UIKeyboardAppearanceAlert;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
        
        [self addSubview:textField];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    [super setTitle:[title stringByAppendingString:@"\n\n\n"]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (first) {
        first = NO;
        textField.text = defaultText;
        [self moveAlert:NO];
    }
    textField.center = CGPointMake(textField.center.x, self.frame.size.height - 100);
}

- (void)show {
    first = YES;
    [super show];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    if (self.valueRequired && [BMStringHelper isEmpty:self.text] && buttonIndex != self.cancelButtonIndex) {
        //Don't dismiss alert
    } else {
        [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    }
}

- (NSString *)text {
    return self.textField.text;
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    NSInteger buttonIndex = self.firstOtherButtonIndex;
    if (buttonIndex < 0) {
        buttonIndex = self.cancelButtonIndex;
    }
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
    return NO;
}

- (void)textDidChange:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textualAlertView:textDidChange:)]) {
        [self.delegate textualAlertView:self textDidChange:self.textField.text];
    }
}

@end

@implementation BMTextualAlertView(Private)

- (void)moveAlert:(BOOL)animated {
    BOOL isLandscape = ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) ||
            ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight);

    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.25f];
    }
    if (isLandscape) {
        self.center = CGPointMake(240.0f, 90.0f);
    } else {
        self.center = CGPointMake(160.0f, 180.0f);
    }

    if (animated) {
        [UIView commitAnimations];
    }
    [self.textField becomeFirstResponder];
 }


@end
