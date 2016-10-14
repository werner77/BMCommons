//
// Created by Werner Altewischer on 04/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "BMAlertViewTestCase.h"
#import <BMCommons/BMAlertController.h>


@implementation BMAlertViewTestCase {

}

- (void)testAlertView {
    [[BMAlertController sharedInstance] showAlertWithTitle:@"Test" message:@"Hele hele hele hele hele hele lange lange lange lange message message message"
                                         cancelButtonTitle:@"Annuleren" otherButtonTitles:@[@"Knop1", @"Knop2"] cancelButtonIndex:2 dismissBlock:^(BMAlertView *alertView, NSInteger buttonIndex) {

                NSLog(@"Alert dismissed with button: %zd", buttonIndex);
            }];
}

@end
