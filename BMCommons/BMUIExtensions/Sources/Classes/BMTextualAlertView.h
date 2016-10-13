//
//  BMTextualAlertView.h
//  BMCommons
//
//  Created by Werner Altewischer.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BMTextualAlertView;

/**
 Delegate protocol for BMTextualAlertView.
 
 Extension of UIAlertViewDelegate.
 */
@protocol BMTextualAlertViewDelegate <UIAlertViewDelegate>

@optional

/**
 Sent to delegate when the text input changes for the alert view.
 */
- (void)textualAlertView:(BMTextualAlertView *)alertView textDidChange:(NSString *)text;

@end

/**
 Alertview with text input functionality.
 */
@interface BMTextualAlertView : UIAlertView

/**
 The text field to use for input.
 */
@property (nonatomic, readonly) UITextField *textField;

/**
 Default text to display.
 */
@property (nonatomic, strong) NSString *defaultText;

/**
 Whether a value is required or not. 
 
 OK can only be clicked if a value is present when this is set to YES.
 */
@property (nonatomic, assign) BOOL valueRequired;

/**
 The text that was input.
 */
- (NSString *)text;

@end
