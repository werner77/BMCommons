//
//  BMDialogHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/10/08.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMCommons/BMUICoreObject.h>

/**
 Helper methods to create and show common alerts/actionsheets.
 */
@interface BMDialogHelper : BMUICoreObject {

}

/**
 Creates and shows an OK/Cancel actionsheet.
 */
+ (UIActionSheet *)dialogOKCancelWithTitle:(NSString *)title withDelegate:(id <UIActionSheetDelegate>)delegate withView:(UIView *)view;

/**
 Creates and shows a YES/NO actionsheet.
 */
+ (UIActionSheet *)dialogYesNoWithTitle:(NSString *)title withDelegate:(id <UIActionSheetDelegate>)delegate withView:(UIView *)view;

/**
 Creates and shows an actionsheet with the supplied parameters.
 */
+ (UIActionSheet *)dialogWithTitle:(NSString *)title 
						  delegate:(id <UIActionSheetDelegate>)delegate 
				 cancelButtonTitle:(NSString *)cancelTitle
			destructiveButtonTitle:(NSString *)destructiveTitle
				 otherButtonTitles:(NSArray *)otherTitles 
						   forView:(UIView *)theView
						   withTag:(NSUInteger)tag;

/**
 Creates and shows an alert with the supplied parameters.
 */
+ (UIAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate;

/**
 Creates and shows an alert with the supplied parameters.
 */
+ (UIAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
@end
