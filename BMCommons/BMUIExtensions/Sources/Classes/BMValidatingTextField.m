//
//  BMValidatingTextField.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/20/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMValidatingTextField.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMInputValueType.h>

@interface BMValidatingTextField()<UITextFieldDelegate>
@end

@implementation BMValidatingTextField {
    id <UITextFieldDelegate> _publicDelegate;
}

@synthesize valueType = _valueType;
@synthesize maxLength = _maxLength;
@synthesize minLength = _minLength;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [super setDelegate:self];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [super setDelegate:self];
    }
    return self;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    _publicDelegate = delegate;
}

- (id<UITextFieldDelegate>)delegate {
    return _publicDelegate;
}

- (void)setValueType:(BMInputValueType *)valueType {
    _valueType = valueType;
    if (valueType) {
        self.keyboardType = valueType.keyboardType;
    }
}

- (void)setText:(NSString *)text {
    if (text.length > self.maxLength && self.maxLength > 0) {
        text = [text substringToIndex:self.maxLength];
    }
    [super setText:text];
}

- (BOOL)allowCharactersInString:(NSString *)string {
    return self.valueType.allowedCharacterSet == nil || [self.valueType.allowedCharacterSet isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:string]];
}

- (BOOL)allowLength:(NSInteger)newLength {
    NSInteger minLength = self.minLength;
    NSInteger maxLength = self.maxLength > 0 ? self.maxLength : NSIntegerMax;
	BOOL lengthValid = (maxLength == 0 || newLength <= maxLength) && newLength >= minLength;
	return lengthValid;
}

- (BOOL)allowNewString:(NSString *)newString {
    BOOL patternMatched = !self.valueType || [BMStringHelper isEmpty:newString] || [self.valueType validateValue:newString];
    return patternMatched;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL charactersAllowed = [self allowCharactersInString:string];
	
    if (!charactersAllowed) {
        return NO;
    }
	
    BOOL lengthValid = [self allowLength:(textField.text.length - range.length + string.length)];
    
    if (!lengthValid) {
        return NO;
    }
    
    NSString *newString = [self.text stringByReplacingCharactersInRange:range withString:string];
    BOOL patternMatched = [self allowNewString:newString];
    
	if (!patternMatched) {
        return NO;
    } else if ([_publicDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [_publicDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([_publicDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [_publicDelegate textFieldShouldBeginEditing:textField];
    } else {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([_publicDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [_publicDelegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([_publicDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [_publicDelegate textFieldShouldEndEditing:textField];
    } else {
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([_publicDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [_publicDelegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if ([_publicDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [_publicDelegate textFieldShouldClear:textField];
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_publicDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [_publicDelegate textFieldShouldReturn:textField];
    } else {
        return YES;
    }
}

@end
