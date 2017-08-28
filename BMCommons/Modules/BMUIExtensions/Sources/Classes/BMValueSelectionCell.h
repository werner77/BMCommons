//
//  BMValueSelectionCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/24/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMObjectPropertyTableViewCell.h>
#import <BMCommons/BMEditViewController.h>

NS_ASSUME_NONNULL_BEGIN

@class BMValueSelectionCell;

@protocol BMValueSelectionCellDelegate <BMObjectPropertyTableViewCellDelegate>

@optional
//Implement this method to manually present the selection view controller instead of the default popover way
- (void)valueSelectionCell:(BMValueSelectionCell *)cell presentSelectionViewController:(id <BMEditViewController>)selectionViewController;

//Implement these two methods to use a manual anchor rect (relative to the view specified) for presenting the popover instead of the default button rect
- (CGRect)anchorRectForPopoverForSelectionCell:(BMValueSelectionCell *)cell;
- (UIView *)viewForPopoverForSelectionCell:(BMValueSelectionCell *)cell;

@end

@interface BMValueSelectionCell : BMObjectPropertyTableViewCell<BMEditViewControllerDelegate, UIPopoverControllerDelegate>

@property (nullable, nonatomic, strong) IBOutlet UIButton *button;
@property (nullable, nonatomic, strong) id selectedValue;
@property (nullable, nonatomic, strong) NSString *buttonImageName;
@property (nullable, nonatomic, strong) NSValueTransformer *displayValueTransformer;
@property (nullable, nonatomic, strong) NSString *placeHolder;
@property (nullable, nonatomic, assign) Class popoverControllerClass;
@property (nonatomic, assign) UIPopoverArrowDirection permittedPopoverArrowDirections;

+ (void)setDefaultButtonImageName:(nullable NSString *)name;
- (nullable id <BMEditViewController>)selectionViewController;
- (void)setSelectedValueWithData:(nullable id)value;
- (nullable NSString *)displayValueForValue:(nullable id)value;
- (nullable NSString *)selectedDisplayValue;
- (void)selectValue;

@end

NS_ASSUME_NONNULL_END
