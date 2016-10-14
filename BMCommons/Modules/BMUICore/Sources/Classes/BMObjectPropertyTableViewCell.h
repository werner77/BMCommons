//
//  BMObjectPropertyTableViewCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/7/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMCommons/BMTableViewCell.h>
#import <BMCommons/BMPropertyDescriptor.h>

@class BMObjectPropertyTableViewCell;

/**
 Delegate protocol for BMObjectPropertyTableViewCell.
 */
@protocol BMObjectPropertyTableViewCellDelegate<NSObject>

@optional

/**
 Sent when the value for this cell has been updated.
 */
- (void)objectPropertyTableViewCell:(BMObjectPropertyTableViewCell *)cell didUpdateObjectWithValue:(id)newValue;

/**
 Sent when the user requests deletion of the specified cell.
 
 Delegate has to take care of the actual deletion or ignore the message when no deletion should occur.
 */
- (void)objectPropertyTableViewCellShouldDelete:(BMObjectPropertyTableViewCell *)cell;

@end

/**
 Base class for table view cells that represent/display/update the value of a property of some arbitrary object.
 */
@interface BMObjectPropertyTableViewCell : BMTableViewCell 

/**
 Delegate for receiving updates when value changes.
 */
@property (nonatomic, weak) id<BMObjectPropertyTableViewCellDelegate> delegate;

/**
 Title label
 */
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

/**
 Optional label
 */
@property (nonatomic, strong) IBOutlet UILabel *commentLabel;

/**
 If set to true validation fails if no value has been supplied for the input field
 */
@property (nonatomic, assign) BOOL valueRequired;

/**
 row height for this cell. 
 
 Is initialized with [BMObjectPropertyTableViewCell heightForValue:] with value nil.
 */
@property (nonatomic, assign) CGFloat rowHeight;

/**
 Whether the current value of this tableview cell is valid.
 
 Calls updateViewForValidityStatus:. This property is set automatically when a new value is set by calling validateValue:transformedValue:.
 */
@property (nonatomic, assign) BOOL valid;

/**
 An optional value transformer to transform the value returned by the property descriptor before supplying it to the cell (transformedValue) 
 and back from view to object (reverseTransformedValue)
 */
@property (nonatomic, strong) NSValueTransformer *valueTransformer;

/**
 The class of values this cell supports, that is after possible conversion by the value transformer.
 
 If you supply a valueTransformerthis class would normally equal the transformedValueClass of the valueTransformer.
 */
+ (Class)supportedValueClass;

/**
 Checks whether the specified value is supported by this cell class.
 
 By default checks whether the value is an instance of the supported value class.
 Excepts any value if supportedClass == nil. Also accepts nil values. Override for an other implementation.
 */
+ (BOOL)isSupportedValue:(id)value;

/**
 Returns the row height for the specified value.
 */
+ (CGFloat)heightForValue:(id)value;

/**
 Method to be called from the UITableViewDataSource method tableView:cellForRowAtIndexPath:.
 
 This method ensures that the value corresponding with the specified property from the supplied object is forwarded to the setViewWithData: method. Override the latter method instead of this one to do something with the data in sub classes.
 */
- (void)constructCellWithObject:(NSObject *)theObject 
				   propertyName:(NSString *)theProperty;

/**
 Same as above but also supplies a title text for display in the title label.
 */
- (void)constructCellWithObject:(NSObject *)theObject 
				   propertyName:(NSString *)theProperty
					  titleText:(NSString *)titleText;

/**
 The property descriptor used by this cell 
 
 Results from calling constructCellWithObject:propertyName.
 */
- (BMPropertyDescriptor *)propertyDescriptor;

@end

@interface BMObjectPropertyTableViewCell(Protected)

/**
 Updates the cell view state by using the object and property supplied in - constructCellWithObject:propertyName.
 Handles value transformation if a valuetransformer is set.
 */
- (void)updateCellValueFromObject;

/**
 Updates the object state from the cell value by using the object and property supplied in - constructCellWithObject:propertyName.
 Handles value transformation if a valuetransformer is set.
 */
- (void)updateObjectWithCellValue;

/**
 Override this method to return the data from the underlying view (to supply it back to the underlying object supplied in - constructCellWithObject:propertyName
 and set its value accordingly).
 If a value transformer is set, the data is transformed inversely after this method returned it.
 */
- (id)dataFromView;

/**
 Sets the view with the data from the value returned from the property of the object as supplied by - constructCellWithObject:propertyName.
 If a value transformer is set, the data is first transformed before it is supplied to this method.
 */
- (void)setViewWithData:(id)value;

/**
 Called when constructCell is called the first time (override to perform any initialization when all IBOutlets are set)
 */
- (void)initialize;

/**
 Returns the data attached to this cell by calling [self.propertyDescriptor callGetter]
 */
- (id)data;

/**
 Updates the view for an invalid value. Override this to do something meaningful (like making text red).
 */
- (void)updateViewForValidityStatus:(BOOL)valid;

/**
 Validates the value set: by default uses KVO validation on using the object/property set. Both the original and the transformed value are supplied (in case of a
 value transformer)
 */
- (BOOL)validateValue:(id *)value transformedValue:(id *)transformedValue;

@end
