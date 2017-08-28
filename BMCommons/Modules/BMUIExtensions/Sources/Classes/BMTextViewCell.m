//
//  BMTextViewCell.m
//  BMCommons
//  Created by Werner Altewischer on 28/10/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <BMCommons/BMTextViewCell.h>
#import "UITextView+BMCommons.h"
#import <BMCommons/BMStringHelper.h>

@interface BMTextViewCell(Private)

- (void)updateTextView;
- (void)setPlaceHolderPresent:(BOOL)present;

@end

@implementation BMTextViewCell {
	IBOutlet UITextView *textView;
	BOOL sizeToFit;
	CGFloat minHeight;
	CGFloat yMargin;
	NSString *placeHolder;
	BOOL placeHolderPresent;
	UIColor *originalTextColor;
}

@synthesize textView, sizeToFit, minHeight, yMargin, placeHolder;

+ (Class)supportedValueClass {
	return [NSString class];
}

#pragma mark -
#pragma mark Initialization and deallocation

- (void)initialize {
	[super initialize];
	self.textView.delegate = self;
	self.target = self.textView;
	self.selector = @selector(becomeFirstResponder);
}

- (void)dealloc {
	self.textView.delegate = nil;
}

#pragma mark -
#pragma mark UITextViewDelegate implementation

- (void)textViewDidChange:(UITextView *)textView {
	[self updateObjectWithCellValue];
}

- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
	return [self shouldChangeText:theTextView.text inRange:range withReplacementText:string];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (placeHolderPresent) {
        self.textView.text = @"";
        [self setPlaceHolderPresent:NO];
    }
    
    if ([self.delegate respondsToSelector:@selector(textCellDidBeginEditing:)]) {
        [(id <BMTextCellDelegate>)self.delegate textCellDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)theTextView {
    [self updateTextView];
	[self.textView resignFirstResponder];
	if ([self.delegate respondsToSelector:@selector(textCellDidEndEditing:)]) {
		[(id <BMTextCellDelegate>)self.delegate textCellDidEndEditing:self];
	}
}

- (BOOL)textViewShouldEndEditing:(UITextView *)theTextView {
	return self.allowEndEditingWithInvalidValue || self.valid;
}

#pragma mark -
#pragma mark Implementation of super class methods

- (id)dataFromView {
	return placeHolderPresent ? @"" : self.textView.text;
}

- (void)setViewWithData:(id)value { 
	self.textView.text = value;
    
    [self updateTextView];
	
	if (self.sizeToFit) {
		[self.textView bmSizeToFitText];
		
		CGFloat height = self.textView.frame.size.height + 2 * self.yMargin;
		if (self.minHeight > 0) {
			height = MAX(height, self.minHeight);
		}
		int intHeight = (int)height;
		if (intHeight % 2 != 0) {
			intHeight++;
		}
		height = (CGFloat)intHeight;
		
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 
								self.frame.size.width, 
								height);
		
		self.textView.center = CGPointMake(self.textView.center.x, height/2);
		self.titleLabel.center = CGPointMake(self.titleLabel.center.x, self.textView.center.y);
	}
}

- (id <UITextInputTraits>)textInputObject {
	return self.textView;
}

@end

@implementation BMTextViewCell(Private)

- (void)setOriginalTextColor:(UIColor *)c {
    if (originalTextColor != c) {
        originalTextColor = c;
    }
}

- (void)setPlaceHolderPresent:(BOOL)present {
    if (present) {
        self.textView.text = self.placeHolder;
        if (!originalTextColor) {
            [self setOriginalTextColor:self.textView.textColor];
        }
        self.textView.textColor = [UIColor grayColor];
        placeHolderPresent = YES;
    } else {
        if (originalTextColor) {
            self.textView.textColor = originalTextColor;
            [self setOriginalTextColor:nil];
        }
        placeHolderPresent = NO;
    }
}

- (void)updateTextView {
    BOOL present = [BMStringHelper isEmpty:self.textView.text] && self.placeHolder;
    [self setPlaceHolderPresent:present];
}

@end

