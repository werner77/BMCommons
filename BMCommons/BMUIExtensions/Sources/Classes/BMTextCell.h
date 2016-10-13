//
//  BMTextCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/24/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMCommons/BMObjectPropertyTableViewCell.h>

@class BMTextCell;

@protocol BMTextCellDelegate<BMObjectPropertyTableViewCellDelegate>

@optional
- (void)textCellDidBeginEditing:(BMTextCell *)cell;
- (void)textCellDidEndEditing:(BMTextCell *)cell;
- (void)textCellInputDidReachMaxLength:(BMTextCell *)cell;
- (void)textCellInputWasInvalid:(BMTextCell *)cell;

@end

@interface BMTextCell : BMObjectPropertyTableViewCell <UITextFieldDelegate> {
	NSCharacterSet *allowedCharacterSet;
	NSInteger maxLength;
	NSInteger minLength;
	NSString *validPattern;
	BOOL allowEndEditingWithInvalidValue;
}

/**
 Character set containing the only values that can be input in the text field. If nil all values are allowed. Values that are not in the set are blocked.
 */
@property (nonatomic, strong) NSCharacterSet *allowedCharacterSet;

/**
 An optional regex pattern that is used for validation of the field.
 */
@property (nonatomic, strong) NSString *validPattern;

/**
 Max length of the input.
 */
@property (nonatomic, assign) NSInteger maxLength;

/**
 Min length of the input, use this if there is a prefix set or something similar.
 */
@property (nonatomic, assign) NSInteger minLength;

/**
 If set to true the text field is allowed to end editing even if an invalid value is currently in the input field. 
 Default is false.
 */
@property (nonatomic, assign) BOOL allowEndEditingWithInvalidValue;

//Protected methods

- (id <UITextInputTraits>)textInputObject;


/**
 Checks whether a range in the specified text can be replaced according to validity rules with the supplied string
 */
- (BOOL)shouldChangeText:(NSString *)theText inRange:(NSRange)range withReplacementText:(NSString *)string;

@end
