//
//  BMEnumeratedValueSelectionViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMEnumeratedValueSelectionViewController.h>
#import <BMCommons/BMPropertyDescriptor.h>
#import <BMCommons/BMLabelCell.h>
#import <BMCommons/BMUICore.h>
#import <BMCommons/NSString+BMUICore.h>

#define DEFAULT_WIDTH 200.0
#define CELL_MARGIN 20.0
#define DEFAULT_FONT [UIFont boldSystemFontOfSize:17.0]

@implementation BMEnumeratedValueSelectionViewController {
	NSArray *possibleValues;
	BMPropertyDescriptor *propertyDescriptor;
	CGFloat widthForViewInPopover;
	NSIndexPath *selectedIndexPath;
	BOOL saveWhenValueIsSelected;
	NSValueTransformer *valueTransformer;
}

@synthesize possibleValues, propertyDescriptor, delegate, saveWhenValueIsSelected, widthForViewInPopover, valueTransformer;

- (void)dealloc {
	self.delegate = nil;
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if (self.widthForViewInPopover <= 0.0f) {
		self.widthForViewInPopover = [self defaultWidthForViewInPopover];
	}
    
    if (self.heightForViewInPopover <= 0.0f) {
        self.heightForViewInPopover = [self defaultHeightForViewInPopover];
    }
	
	self.preferredContentSize = CGSizeMake(self.widthForViewInPopover,
												  self.heightForViewInPopover);
	
	if (self.firstLoad) {
		id currentObject = [self.propertyDescriptor callGetter];
        selectedIndexPath = [self indexPathForValue:currentObject];
	}
    
    self.tableView.rowHeight = [self tableViewRowHeight];
}

- (void)localize {
    [super localize];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:BMUICoreLocalizedString(@"button.title.cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
	self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:BMUICoreLocalizedString(@"button.title.save", @"Save") style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed)];
	self.navigationItem.rightBarButtonItem = saveButton;
}

#pragma mark -
#pragma mark UITableViewController methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return possibleValues.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id selectedObject = [self valueForIndexPath:indexPath];
    
    UITableViewCell *cell = [self cellForTableView:theTableView forRowAtIndexPath:indexPath withObject:selectedObject];
    
    BOOL selected = [indexPath isEqual:selectedIndexPath];
    [self applySelectedStyle:selected toCell:cell];
	return cell;
}

- (UITableViewCell *)cellForTableView:(UITableView *)theTableView forRowAtIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
	static NSString *reuseIdentifier = @"__ValueCell";
	
	//To be overridden by sub classes to provide a meaningfull cell
	UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	}
	
	cell.textLabel.font = [self fontForCellLabel];
	cell.textLabel.text = [self labelFromValue:object];
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell;
	if (selectedIndexPath != nil) {
		cell = [theTableView cellForRowAtIndexPath:selectedIndexPath];
        [self applySelectedStyle:NO toCell:cell];
	}
	
	selectedIndexPath = indexPath;
	
	cell = [theTableView cellForRowAtIndexPath:indexPath];
    
    [self applySelectedStyle:YES toCell:cell];
    
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (self.saveWhenValueIsSelected) {
		[self saveButtonPressed];
	}
}

#pragma mark -
#pragma mark Actions

- (IBAction)cancelButtonPressed {
	[self.delegate editViewControllerWasCancelled:self];
}

- (IBAction)saveButtonPressed {
	id theSelectedValue = nil;
	if (selectedIndexPath != nil) {
		theSelectedValue = [self valueForIndexPath:selectedIndexPath];
	}
	[self.propertyDescriptor callSetter:theSelectedValue];
    [self didSelectValue:theSelectedValue];
}

#pragma mark - Protected methods

- (void)didSelectValue:(id)value {
    [self.delegate editViewController:self didSelectValue:value];
}

- (CGFloat)defaultWidthForViewInPopover {
	//Select a default width based on the possible values
	
	CGFloat defaultWidth = DEFAULT_WIDTH;
	if (self.possibleValues.count > 0) {
		CGFloat maxWidth = 0.0f;
		
		for (id possibleValue in possibleValues) {
            NSString *s = [self labelFromValue:possibleValue];
			CGSize size = [s bmSizeWithFont:[self fontForCellLabel]];
			
			maxWidth = MAX(maxWidth, size.width);
		}
		defaultWidth = maxWidth + 2 * CELL_MARGIN;
	}
	return defaultWidth;
}

- (CGFloat)tableViewRowHeight {
    return BMSTYLEVAR(tableViewRowHeight);
}

- (CGFloat)defaultHeightForViewInPopover {
    CGFloat ret = ([self tableViewRowHeight] * possibleValues.count) - 1;
    return MAX(ret, 0.0f);
}

- (UIFont *)fontForCellLabel {
	return DEFAULT_FONT;
}

- (void)applySelectedStyle:(BOOL)selected toCell:(UITableViewCell *)cell {
    if (selected) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
}

- (id)valueForIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    return index >= 0 && index < possibleValues.count ? [possibleValues objectAtIndex:index] : nil;
}

- (NSIndexPath *)indexPathForValue:(id)object {
    NSUInteger index = [possibleValues indexOfObject:object];
    if (index == NSNotFound) {
        return nil;
    } else {
        return [NSIndexPath indexPathForRow:index inSection:0];
    }
}

- (NSString *)labelFromValue:(id)value {
    if (self.valueTransformer) {
        value = [self.valueTransformer transformedValue:value];
    }
    return [value description];
}

@end
