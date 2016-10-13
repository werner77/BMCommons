//
//  BMValueSelectionCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/24/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMUICore/BMObjectPropertyTableViewCell.h>
#import <BMUIExtensions/BMEditViewController.h>

@class BMValueSelectionCell;

@protocol BMValueSelectionCellDelegate <BMObjectPropertyTableViewCellDelegate>

@optional
//Implement this method to manually present the selection view controller instead of the default popover way
- (void)valueSelectionCell:(BMValueSelectionCell *)cell presentSelectionViewController:(id <BMEditViewController>)selectionViewController;

//Implement these two methods to use a manual anchor rect (relative to the view specified) for presenting the popover instead of the default button rect
- (CGRect)anchorRectForPopoverForSelectionCell:(BMValueSelectionCell *)cell;
- (UIView *)viewForPopoverForSelectionCell:(BMValueSelectionCell *)cell;

@end

@interface BMValueSelectionCell : BMObjectPropertyTableViewCell<BMEditViewControllerDelegate, UIPopoverControllerDelegate> {
	IBOutlet UIButton *button;
	UIPopoverController *popoverController;
	id selectedValue;	
	NSValueTransformer *displayValueTransformer;
	NSString *placeHolder;
    Class popoverControllerClass;
}

@property (nonatomic, strong) IBOutlet UIButton *button;
@property (nonatomic, strong) id selectedValue;
@property (nonatomic, strong) NSString *buttonImageName;
@property (nonatomic, strong) NSValueTransformer *displayValueTransformer;
@property (nonatomic, strong) NSString *placeHolder;
@property (nonatomic, assign) Class popoverControllerClass;
@property (nonatomic, assign) UIPopoverArrowDirection permittedPopoverArrowDirections;

+ (void)setDefaultButtonImageName:(NSString *)name;
- (id <BMEditViewController>)selectionViewController;
- (void)setSelectedValueWithData:(id)value;
- (NSString *)displayValueForValue:(id)value;
- (NSString *)selectedDisplayValue;
- (void)selectValue;

@end
