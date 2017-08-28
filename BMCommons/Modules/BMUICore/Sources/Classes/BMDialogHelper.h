//
//  BMDialogHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/10/08.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMCommons/BMUICoreObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Helper methods to create and show common alerts/actionsheets.
 */
@interface BMDialogHelper : BMUICoreObject {

}

/**
 Creates and shows an OK/Cancel actionsheet.
 */
+ (UIActionSheet *)dialogOKCancelWithTitle:(nullable NSString *)title withDelegate:(nullable id <UIActionSheetDelegate>)delegate inView:(UIView *)view;

/**
 Creates and shows a YES/NO actionsheet.
 */
+ (UIActionSheet *)dialogYesNoWithTitle:(nullable NSString *)title withDelegate:(nullable id <UIActionSheetDelegate>)delegate inView:(UIView *)view;

/**
 Creates and shows an actionsheet with the supplied parameters.
 */
+ (UIActionSheet *)dialogWithTitle:(nullable NSString *)title
						  delegate:(nullable id <UIActionSheetDelegate>)delegate
				 cancelButtonTitle:(nullable NSString *)cancelTitle
			destructiveButtonTitle:(nullable NSString *)destructiveTitle
				 otherButtonTitles:(nullable NSArray *)otherTitles
							inView:(UIView *)theView
						   withTag:(NSUInteger)tag;

/**
 Creates and shows an alert with the supplied parameters.
 */
+ (UIAlertView *)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id)delegate;

/**
 Creates and shows an alert with the supplied parameters.
 */
+ (UIAlertView *)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message delegate:(nullable id)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitles, ...;

@end

NS_ASSUME_NONNULL_END
