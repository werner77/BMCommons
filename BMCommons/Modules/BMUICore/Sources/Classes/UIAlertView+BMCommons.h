//
//  UIAlertView+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 31/05/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Adds a context to an alert view.
 */
@interface UIAlertView(BMCommons)

/**
 The context. 
 
 Set it to nil when done with the actionsheet to avoid a memory leak.
 */
@property (nonatomic, strong) id bmContext;

@end
