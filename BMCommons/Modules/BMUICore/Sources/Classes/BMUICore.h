//
//  BMUICore.h
//  BMCommons
//
//  Created by Werner Altewischer on 21/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//
#import <BMCommons/BMCore.h>
#import <BMCommons/BMUICoreObject.h>
#import <BMCommons/BMStyleSheet.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
// Dimensions of common iPhone OS Views

#define BM_IPHONE_SCREEN_WIDTH 320
#define BM_IPHONE_SCREEN_HEIGHT 480
#define BM_IPHONE5_SCREEN_HEIGHT 568
#define BM_STATUSBAR_HEIGHT 20
#define BM_NAVBAR_HEIGHT 44
#define BM_TABBAR_HEIGHT 49
#define BM_ROW_HEIGHT 44
#define BM_TOOLBAR_HEIGHT 44
#define BM_LANDSCAPE_TOOLBAR_HEIGHT 33
#define BM_KEYBOARD_HEIGHT 216
#define BM_LANDSCAPE_KEYBOARD_HEIGHT 160

///////////////////////////////////////////////////////////////////////////////////////////////////
// Color helpers

#define BMRGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define BMRGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define BMHSVCOLOR(h,s,v) [UIColor colorWithHue:h saturation:s value:v alpha:1]
#define BMHSVACOLOR(h,s,v,a) [UIColor colorWithHue:h saturation:s value:v alpha:a]

#define BMRGBA(r,g,b,a) r/255.0, g/255.0, b/255.0, a

///////////////////////////////////////////////////////////////////////////////////////////////////
// Style

#define BMSTYLESHEET ((id)[BMStyleSheet currentStyleSheet])
#define BMSTYLEVAR(_VARNAME) [BMSTYLESHEET _VARNAME]

///////////////////////////////////////////////////////////////////////////////////////////////////
// Animation

#define BM_SLOW_TRANSITION_DURATION 0.4

/**
 * The standard duration for transition animations.
 */
#define BM_TRANSITION_DURATION 0.3

#define BM_FAST_TRANSITION_DURATION 0.2

#define BM_FLIP_TRANSITION_DURATION 0.7

#define BMRectMakeIntegral(a,b,c,d) CGRectIntegral(CGRectMake(a,b,c,d))

/**
 * Returns a rectangle whose edges have been added to the insets.
 */
CGRect BMRectInset(CGRect rect, UIEdgeInsets insets);

/**
 * Tests if the device has phone capabilities.
 */
BOOL BMIsPhoneSupported(void);

/**
 Forces interface orientation to change without a device orientation change.
 */
void BMRotateToOrientation(UIInterfaceOrientation orientation);

/**
 Returns true if the current device is an iPhone 5 (or device with similar dimensions).
 */
BOOL BMIsIPhone5(void);

/**
 * Gets the current device orientation.
 */
UIDeviceOrientation BMDeviceOrientation(void);

/**
 * Gets the current interface orientation.
 */
UIInterfaceOrientation BMInterfaceOrientation(void);

/**
 * Checks if the orientation is portrait, landscape left, or landscape right.
 *
 * This helps to ignore upside down and flat orientations.
 */
BOOL BMIsSupportedOrientation(UIInterfaceOrientation orientation);

/**
 * Gets the rotation transform for a given orientation.
 */
CGAffineTransform BMRotateTransformForOrientation(UIInterfaceOrientation orientation);

/**
 * Gets the bounds of the screen with device orientation factored in.
 */
CGRect BMScreenBounds(void);

/**
 * Gets the application frame.
 */
CGRect BMApplicationFrame(void);

/**
 * Gets the application frame below the navigation bar.
 */
CGRect BMNavigationFrame(void);

/**
 * Gets the application frame below the navigation bar and above the keyboard.
 */
CGRect BMKeyboardNavigationFrame(void);

/**
 * Gets the application frame below the navigation bar and above a toolbar.
 */
CGRect BMToolbarNavigationFrame(void);

/**
 * The height of the area containing the status bar and possibly the in-call status bar.
 */
CGFloat BMStatusHeight(void);

/**
 * The height of the area containing the status bar and navigation bar.
 */
CGFloat BMBarsHeight(void);

/**
 * The height of a toolbar.
 */
CGFloat BMToolbarHeight(void);
CGFloat BMToolbarHeightForOrientation(UIInterfaceOrientation orientation);

/**
 * The height of the keyboard.
 */
CGFloat BMKeyboardHeight(void);
CGFloat BMKeyboardHeightForOrientation(UIInterfaceOrientation orientation);

/**
 * Increment the number of active network requests.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 */
void BMNetworkRequestStarted(void);

/**
 * Decrement the number of active network requests.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 */
void BMNetworkRequestStopped(void);

#define BMUICoreLocalizedString(key, comment) NSLocalizedStringFromTableInBundle(key, @"BMUICore", [BMUICore bundle], comment)

/**
 BMUICore Module
 */
@interface BMUICore : NSObject
{
    
}

+ (id)instance;
+ (NSBundle *)bundle;

@end
