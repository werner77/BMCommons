//
//  BMTextFieldCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/7/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMCommons/BMTextCell.h>
#import <BMCommons/BMValidatingTextField.h>

NS_ASSUME_NONNULL_BEGIN

@class BMTextFieldCell;

@protocol BMTextFieldCellDelegate<BMTextCellDelegate>

@optional
- (BOOL)textFieldCellShouldReturn:(BMTextFieldCell *)cell;

@end

@interface BMTextFieldCell : BMTextCell <UITextFieldDelegate>

@property (nullable, nonatomic, strong) IBOutlet BMValidatingTextField *valueTextField;

- (void)constructCellWithObject:(nullable NSObject *)theObject
						   propertyName:(nullable NSString *)thePropertyName
					  titleText:(nullable NSString *)titleText
				placeHolderText:(nullable NSString *)placeHolderText;

- (void)textFieldWasChanged:(UITextField *)textField;
	
@end

NS_ASSUME_NONNULL_END
