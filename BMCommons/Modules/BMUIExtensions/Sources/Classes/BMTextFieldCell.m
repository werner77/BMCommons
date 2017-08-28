//
//  BMTextFieldCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 10/7/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMTextFieldCell.h>
#import <BMCommons/BMTextField.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMRegexKitLite.h>

@implementation BMTextFieldCell {
	IBOutlet BMValidatingTextField *valueTextField;
}

@synthesize valueTextField;

+ (Class)supportedValueClass {
	return [NSString class];
}

#pragma mark -
#pragma mark Initialization and cleanup

- (void)constructCellWithObject:(NSObject *)theObject 
						   propertyName:(NSString *)thePropertyName
					  titleText:(NSString *)titleText
				placeHolderText:(NSString *)placeHolderText	{
	self.valueTextField.placeholder = placeHolderText;
	[super constructCellWithObject:theObject propertyName:thePropertyName titleText:titleText];	
}

- (void)initialize {
	[super initialize];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChangedNotification) name:UITextFieldTextDidChangeNotification object:self.valueTextField];
	self.valueTextField.delegate = self;
	self.target = self.valueTextField;
	self.selector = @selector(becomeFirstResponder);
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.valueTextField.delegate = nil;
}

- (void)textFieldChangedNotification {
    [self textFieldWasChanged:self.valueTextField];
}

- (void)textFieldWasChanged:(UITextField *)textField {
	[self updateObjectWithCellValue];
}

#pragma mark -
#pragma mark UITextFieldDelegate implementation

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self.valueTextField resignFirstResponder];
	if ([self.delegate respondsToSelector:@selector(textCellDidEndEditing:)]) {
		[(id <BMTextCellDelegate>)self.delegate textCellDidEndEditing:self];
	}
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textCellDidBeginEditing:)]) {
        [(id <BMTextCellDelegate>)self.delegate textCellDidBeginEditing:self];
    }
    [self updateObjectWithCellValue];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	BOOL isValid = [BMStringHelper isEmpty:textField.text] || self.valid;
	return self.allowEndEditingWithInvalidValue || isValid;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
	if ([self.delegate respondsToSelector:@selector(textFieldCellShouldReturn:)]) {
		shouldReturn = [(id <BMTextFieldCellDelegate>)self.delegate textFieldCellShouldReturn:self];
	}
    if (shouldReturn) {
        [self.valueTextField resignFirstResponder];
    }
	return shouldReturn;
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return [self shouldChangeText:theTextField.text inRange:range withReplacementText:string];
}

#pragma mark -
#pragma mark Implementation of super class methods

- (id)dataFromView {
	return self.valueTextField.text;
}

- (void)setViewWithData:(id)value {
	self.valueTextField.text = value;
}

- (id <UITextInputTraits>)textInputObject {
	return self.valueTextField;
}

@end
