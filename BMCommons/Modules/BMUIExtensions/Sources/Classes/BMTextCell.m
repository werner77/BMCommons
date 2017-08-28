//
//  BMTextCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/24/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMTextCell.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMRegexKitLite.h>

@implementation BMTextCell {
	NSCharacterSet *allowedCharacterSet;
	NSInteger maxLength;
	NSInteger minLength;
	NSString *validPattern;
	BOOL allowEndEditingWithInvalidValue;
}

@synthesize maxLength, minLength, allowedCharacterSet, validPattern, allowEndEditingWithInvalidValue;

+ (Class)supportedValueClass {
	return [NSString class];
}

#pragma mark -
#pragma mark Initialization and cleanup


- (void)prepareForReuse {
	[super prepareForReuse];
	self.validPattern = nil;
	self.allowedCharacterSet = nil;
	self.maxLength = 0;
	self.minLength = 0;
}

#pragma mark -
#pragma mark Implementation of super class methods

- (BOOL)validateValue:(id *)value transformedValue:(id *)transformedValue {
	BOOL patternMatched = [BMStringHelper isEmpty:self.validPattern] || [BMStringHelper isEmpty:*transformedValue] || 
			[*transformedValue isMatchedByRegex:self.validPattern];
	return patternMatched && [super validateValue:value transformedValue:transformedValue];
}

#pragma mark -
#pragma mark Protected methods

- (id <UITextInputTraits>)textInputObject {
	return nil;
}

- (BOOL)shouldChangeText:(NSString *)theText inRange:(NSRange)range withReplacementText:(NSString *)string {
	BOOL charactersAllowed = allowedCharacterSet == nil || [allowedCharacterSet isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:string]];
	
	if (!charactersAllowed && [self.delegate respondsToSelector:@selector(textCellInputWasInvalid:)]) {
		[(id <BMTextCellDelegate>)self.delegate textCellInputWasInvalid:self];
	}
	
	NSInteger newLength = (theText.length - range.length + string.length);
	
	BOOL lengthValid = (maxLength == 0 || newLength <= maxLength) && newLength >= minLength;
	if (!lengthValid && [self.delegate respondsToSelector:@selector(textCellInputDidReachMaxLength:)]) {
		[(id <BMTextCellDelegate>)self.delegate textCellInputDidReachMaxLength:self];
	}
	
	return charactersAllowed && lengthValid;
	
}

@end
