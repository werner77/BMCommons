//
//  BMTextField.m
//  BMCommons
//
//  Created by Werner Altewischer on 1/11/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMTextField.h"

@implementation BMTextField

- (void)setKind:(BMTextFieldKind)kind {

    //Defaults
    if (kind == BMTextFieldKindEmailAddress) {
        self.keyboardType = UIKeyboardTypeEmailAddress;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.secureTextEntry = NO;
    } else if (kind == BMTextFieldKindPassword) {
        self.keyboardType = UIKeyboardTypeDefault;
        self.secureTextEntry = YES;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    } else if (kind == BMTextFieldKindLitteral) {
        self.keyboardType = UIKeyboardTypeDefault;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.secureTextEntry = NO;
    } else if (kind == BMTextFieldKindNumeric) {
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.keyboardType = UIKeyboardTypeDecimalPad;
        self.secureTextEntry = NO;
    } else {
        //Default
    }

}

@end
