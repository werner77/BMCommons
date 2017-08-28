//
//  BMTextField.h
//  BMCommons
//
//  Created by Werner Altewischer on 1/11/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BMTextFieldKind) {
	BMTextFieldKindDefault,
	BMTextFieldKindLitteral,	
	BMTextFieldKindPassword,
	BMTextFieldKindEmailAddress,
    BMTextFieldKindNumeric,
};

/**
Default text field kinds that set parameters to support common input functionality
*/
@interface BMTextField : UITextField {

}

/**
 Sets the kind of this text field and adjusts keyboard type, autocorrect mode, etc accordingly.
 */
- (void)setKind:(BMTextFieldKind)kind;

@end

NS_ASSUME_NONNULL_END
