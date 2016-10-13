//
//  BMValidatingTextField.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/20/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMUICore/BMTextField.h>

@class BMInputValueType;

/**
 Text field with support for validation using a BMValueType instance.
 */
@interface BMValidatingTextField : BMTextField

/**
 The BMValueType describing the valid value for input for this text field.
 
 @see BMValueType
 */
@property (nonatomic, strong) BMInputValueType *valueType;

/**
 The min length in characters of allowed text for this text field.
 
 Defaults to 0.
 */
@property (nonatomic, assign) NSInteger minLength;

/**
 The max length in characters of allowed text for this text field.
 
 Defaults to 0 which is unlimited.
 */
@property (nonatomic, assign) NSInteger maxLength;

@end

@interface BMValidatingTextField(Protected)

/**
 Decides whether to allow updating the text field with the characters in the supplied string.
 
 Default implementation is to check the valueType if set and to disallow the change if the [BMValueType allowedCharacterSet] does not contain all the characters. The text field won't update.
 If you want to act differently (e.g. by marking the text red) you should override this method and return YES if you want to allow the change.
 */
- (BOOL)allowCharactersInString:(NSString *)string;

/**
 Decides whether to allow updating the text field with a string of the nex length.
 
 Default implementation checks the minLength and maxLength parameters set of this instance.
 */
- (BOOL)allowLength:(NSInteger)newLength;

/**
 Whether to allow the new string as update for this text field. 
 
 Default implementation returns the value returned by [BMValueType validateValue:] for the valueType set.
 If you want to act differently (e.g. by marking the text red) you should override this method and return YES if you want to allow the change.
 */
- (BOOL)allowNewString:(NSString *)newString;

@end
