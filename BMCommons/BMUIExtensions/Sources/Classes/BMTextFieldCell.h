//
//  BMTextFieldCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/7/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMUIExtensions/BMTextCell.h>
#import <BMUIExtensions/BMValidatingTextField.h>

@class BMTextFieldCell;

@protocol BMTextFieldCellDelegate<BMTextCellDelegate>

@optional
- (BOOL)textFieldCellShouldReturn:(BMTextFieldCell *)cell;

@end

@interface BMTextFieldCell : BMTextCell <UITextFieldDelegate> {
	IBOutlet BMValidatingTextField *valueTextField;
}

@property (nonatomic, strong) IBOutlet BMValidatingTextField *valueTextField;

- (void)constructCellWithObject:(NSObject *)theObject 
						   propertyName:(NSString *)thePropertyName
					  titleText:(NSString *)titleText
				placeHolderText:(NSString *)placeHolderText;

- (void)textFieldWasChanged:(UITextField *)textField;
	

@end
