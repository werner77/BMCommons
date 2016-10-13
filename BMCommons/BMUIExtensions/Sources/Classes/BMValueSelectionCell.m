//
//  BMValueSelectionCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/24/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMValueSelectionCell.h"
#import <BMUICore/UIButton+BMCommons.h>
#import <BMUIExtensions/BMEnumeratedValueSelectionViewController.h>
#import <BMCore/BMPropertyDescriptor.h>
#import <BMCore/BMStringHelper.h>
#import <BMUIExtensions/BMEditViewController.h>
#import "BMEnumeratedValueToStringTransformer.h"
#import <BMUICore/BMUICore.h>

@implementation BMValueSelectionCell

static NSString *defaultButtonImageName = @"BMUICore.bundle/selection_box.png";

@synthesize selectedValue, displayValueTransformer, placeHolder, popoverControllerClass, buttonImageName, button;

+ (void)setDefaultButtonImageName:(NSString *)name {
    if (defaultButtonImageName != name) {
        defaultButtonImageName = name;
    }
}

- (void)dealloc {
	[popoverController dismissPopoverAnimated:NO];
	BM_RELEASE_SAFELY(placeHolder);
	BM_RELEASE_SAFELY(popoverController);
	BM_RELEASE_SAFELY(button);
	BM_RELEASE_SAFELY(selectedValue);
	BM_RELEASE_SAFELY(displayValueTransformer);
    BM_RELEASE_SAFELY(buttonImageName);
}

- (void)initialize {
	[super initialize];
    
    self.permittedPopoverArrowDirections = (UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown);
    
    Class c = NSClassFromString(@"WEPopoverController");
    
    if (c == nil) {
        //WEPopover not available, use the UIPopover instead which will only work on the iPad
        c = [UIPopoverController class];
    }
    
    self.popoverControllerClass = c;
    
    NSString *imageName = self.buttonImageName == nil ? defaultButtonImageName : self.buttonImageName;
    
	UIImage *btnImage = [UIImage imageNamed:imageName];
	[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
	[button setTitleEdgeInsets:UIEdgeInsetsMake(6.0, 9.0, 0.0, 30.0)];
	[button setBackgroundImage:[btnImage stretchableImageWithLeftCapWidth:(int)(btnImage.size.width/2) 
															 topCapHeight:0]
																 forState:UIControlStateNormal];

	[button bmSetTarget:self action:@selector(selectValue)];
}

- (void)prepareForReuse {
	[super prepareForReuse];
	self.selectedValue = nil;
}

#pragma mark -
#pragma mark Public methods

- (id <BMEditViewController>)selectionViewController {
	return nil;
}

- (void)selectValue {
	if (!popoverController) {
		id <BMEditViewController> vc = [self selectionViewController];
        if (vc) {
            vc.delegate = self;
            
            if ([self.delegate respondsToSelector:@selector(valueSelectionCell:presentSelectionViewController:)]) {
                [(id <BMValueSelectionCellDelegate>)self.delegate valueSelectionCell:self presentSelectionViewController:vc];
            } else {
                popoverController = [[[self popoverControllerClass] alloc] initWithContentViewController:(UIViewController *)vc];
                popoverController.delegate = self;
                
                CGRect r = button.bounds;
                UIView *v = button;
                
                if ([self.delegate respondsToSelector:@selector(anchorRectForPopoverForSelectionCell:)]) {
                    r = [(id <BMValueSelectionCellDelegate>)self.delegate anchorRectForPopoverForSelectionCell:self];
                }
                
                if ([self.delegate respondsToSelector:@selector(viewForPopoverForSelectionCell:)]) {
                    v = [(id <BMValueSelectionCellDelegate>)self.delegate viewForPopoverForSelectionCell:self];
                }
                
                [popoverController presentPopoverFromRect:r inView:v 
                                 permittedArrowDirections:self.permittedPopoverArrowDirections
                                                 animated:YES];    
            }
        }
	}
}

- (void)setSelectedValueWithData:(id)value {
	self.selectedValue = value;
}

- (NSString *)displayValueForValue:(id)value {
	NSString *theTitle = nil;
	if (self.displayValueTransformer) {
		theTitle = [[self.displayValueTransformer transformedValue:value] description];
	} else {
		theTitle = [value description];
	}
	return theTitle;
}

- (NSString *)selectedDisplayValue {
	return [self displayValueForValue:self.selectedValue];
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate Implementation

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)thePopoverController {
	BM_RELEASE_SAFELY(popoverController);
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)thePopoverController {
	return YES;
}

#pragma mark -
#pragma mark BMEditViewControllerDelegate Implementation

- (void)editViewController:(id <BMEditViewController>)vc didSelectValue:(id)value {
	[self updateObjectWithCellValue];
	[self updateCellValueFromObject];
	[popoverController dismissPopoverAnimated:YES];
	BM_RELEASE_SAFELY(popoverController);
}

- (void)editViewControllerWasCancelled:(id <BMEditViewController>)vc {
	[popoverController dismissPopoverAnimated:YES];
	BM_RELEASE_SAFELY(popoverController);
}

#pragma mark -
#pragma mark Implementation of superclass methods

- (id)dataFromView {
	return self.selectedValue;
}

- (void)setViewWithData:(id)value {
	[self setSelectedValueWithData:value];
	
	NSString *title = self.selectedDisplayValue;
	if ([BMStringHelper isEmpty:title]) {
		title = self.placeHolder;
        UIColor *c = [UIColor grayColor];
		[button setTitleColor:c forState:UIControlStateNormal];
        [button setTitleColor:c forState:UIControlStateHighlighted];
	} else {
        UIColor * c = [UIColor blackColor];
		[button setTitleColor:c forState:UIControlStateNormal];
        [button setTitleColor:c forState:UIControlStateHighlighted];
	}
	[button setTitle:title forState:(UIControlStateNormal)];
}

- (void)updateViewForValidityStatus:(BOOL)isValid {
}

@end
