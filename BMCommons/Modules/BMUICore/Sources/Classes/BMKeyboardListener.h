//
//  BMKeyboardListener.h
//  BMCommons
//
//  Created by Werner Altewischer on 8/12/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMUICoreObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Listener for UIKeyboard notifications.
 
 Use the property visible to see if the keyboard is currently up or not.
 */
@interface BMKeyboardListener : BMUICoreObject

/**
 Returns YES if and only if the keyboard is up.
 */
@property (nonatomic, assign, getter = isVisible) BOOL visible;

/**
 The singleton instance.
 */
+ (BMKeyboardListener *) sharedInstance;

@end

NS_ASSUME_NONNULL_END
