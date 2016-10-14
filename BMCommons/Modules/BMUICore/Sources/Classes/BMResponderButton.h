//
//  BMCustomButton.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/3/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Button that can become a first responder when the user touches it.
 
 This is handy in conjunction with BMTableViewController automatic scrolling behavior, which listens for first responder status of views.
 */
@interface BMResponderButton : UIButton

@end
