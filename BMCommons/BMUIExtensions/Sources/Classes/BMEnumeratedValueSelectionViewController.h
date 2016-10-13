//
//  BMEnumeratedValueSelectionViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <BMUICore/BMTableViewController.h>
#import <BMUIExtensions/BMEditViewController.h>

@class BMPropertyDescriptor;

/**
 * Table view controller for selecting a value from a list (sort of a picker style TableViewController).
 */
@interface BMEnumeratedValueSelectionViewController : BMTableViewController<BMEditViewController> {
	NSArray *possibleValues;
	BMPropertyDescriptor *propertyDescriptor;
	id <BMEditViewControllerDelegate> __weak delegate;
	CGFloat widthForViewInPopover;
	NSIndexPath *selectedIndexPath;
	BOOL saveWhenValueIsSelected;
	NSValueTransformer *valueTransformer;
}

/**
 * The array of possible values to choose from.
 */
@property (nonatomic, strong) NSArray *possibleValues;

/**
 Value transformer for converting the possible values to a string for display. If not set, the description method is used to
 generate a string for each value.
 */
@property (nonatomic, strong) NSValueTransformer *valueTransformer;

/**
 * If true the save method will be called automatically when a new value is selected. Default is false.
 */
@property (nonatomic, assign) BOOL saveWhenValueIsSelected;

/**
 * Property descriptor to use for setting the value when value is chosen and to initialize the view with the currently chosen value.
 */
@property (nonatomic, strong) BMPropertyDescriptor *propertyDescriptor;

/**
 * Delegate to receive BMEditViewController events.
 */
@property (nonatomic, weak) id <BMEditViewControllerDelegate> delegate;

/**
 The width for the view in popover. If not set the default is chosen.
 
 @see defaultWidthForViewInPopover
 */
@property (nonatomic, assign) CGFloat widthForViewInPopover;

/**
 The height for the view in popover. If not set the default is chosen.
 
 @see defaultHeightForViewInPopover
 */
@property (nonatomic, assign) CGFloat heightForViewInPopover;

/**
 * Override this method to provide a proper cell instead of the normal method from the UITableViewDatasource protocol.
 * Default is to provide a UITableViewCell with Default style with the textLabel set with the description of the object corresponding to that row.
 */
- (UITableViewCell *)cellForTableView:(UITableView *)theTableView forRowAtIndexPath:(NSIndexPath *)indexPath withObject:(id)object;

/**
 * Cancel button action
 */
- (IBAction)cancelButtonPressed;

/**
 * Save button action
 */
- (IBAction)saveButtonPressed ;

@end

@interface BMEnumeratedValueSelectionViewController(Protected)

/**
 Returns the default width which is used if none is set explicitly
 */
- (CGFloat)defaultWidthForViewInPopover;

/**
 Returns the default height which is used if none is set explicitly
 */
- (CGFloat)defaultHeightForViewInPopover;

/**
 Returns the font to use for the labels of the cells. By default returns a bold system font of size 17.0
 */
- (UIFont *)fontForCellLabel;

/**
 Applies the style applicable for the specified selection state to the specified cell.
 
 Default is to display the ceckmark accessory.
 */
- (void)applySelectedStyle:(BOOL)selected toCell:(UITableViewCell *)cell;

/**
 Returns the possible value for the specified index path or nil if not found.
 
 Default is the value at indexPath.row index in the possibleValues array.
 */
- (id)valueForIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the indexPath corresponding to the specified object or nil if not found.
 
 By default returns the index path where section=0 and row=the index of the object in the possibleValues array.
 */
- (NSIndexPath *)indexPathForValue:(id)object;

/**
 Called when the controller has selected and saved a value.
 
 Default implementation is to notify the delegate.
 */
- (void)didSelectValue:(id)value;

/**
 Returns the label for the specified value. By default returns [value description] if no valueTransformer is set. Otherwise the valueTransformer is used and the description of the transformed value is returned.
 */
- (NSString *)labelFromValue:(id)value;

/**
 Returns the rowheight used by the table view which is used to calculate the defaultHeightForViewInPopover in viewDidLoad.
 */
- (CGFloat)tableViewRowHeight;

@end
