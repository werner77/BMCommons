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
#import <BMCommons/BMViewLayout.h>

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

NS_ASSUME_NONNULL_BEGIN

/**
 * Returns a rectangle whose edges have been added to the insets.
 */
CGRect BMRectInset(CGRect rect, UIEdgeInsets insets);

/**
 * Returns a point aligned to the specified rect with the specified alignment.
 */
CGPoint BMPointAlignedToRect(BMViewLayoutAlignment alignment, CGRect rect);

/**
 * Returns a point aligned to the specified rect with the specified insets and alignment.
 */
CGPoint BMPointAlignedToRectWithInsets(BMViewLayoutAlignment alignment, CGRect rect, UIEdgeInsets insets);

/**
 * Returns a point aligned to the specified edges of the specified size object, assuming a rectangle with origin at (0, 0, size.width, size.height)
 */
CGPoint BMPointAlignedToSize(BMViewLayoutAlignment alignment, CGSize size);

/**
 * Returns a point aligned to the specified edges of the specified size object, assuming a rectangle (insets.left, inset.right, size.width - insets.left - insets.right, size.height - insets.top - insets.bottom)
 */
CGPoint BMPointAlignedToSizeWithInsets(BMViewLayoutAlignment alignment, CGSize size, UIEdgeInsets insets);

/**
 * Returns the result of CGRectIntegral(CGRectMake(top, left, bottom, right))
 */
CGRect BMRectMakeIntegral(CGFloat x, CGFloat y, CGFloat width, CGFloat height);

/**
 * Returns an integral point by rounding x and y.
 */
CGPoint BMPointMakeIntegral(CGFloat x, CGFloat y);

/**
 * Returns an integral size by taking the ceiling of both width and height.
 */
CGSize BMSizeMakeIntegral(CGFloat width, CGFloat height);

/**
 * Returns a CGSize struct by insetting the supplied size with the specified insets.
 */
CGSize BMSizeInset(CGSize size, UIEdgeInsets edgeInsets);

/**
 * Returns the inverted edge insets (minus of top, left, bottom, right).
 */
UIEdgeInsets BMEdgeInsetsInvert(UIEdgeInsets edgeInsets);

/**
 * Returns an integral edge insets by rounding top, left, bottom and right.
 */
UIEdgeInsets BMEdgeInsetsMakeIntegral(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right);

/**
 * Returns the resulting edge insets by adding insets2 to insets1.
 */
UIEdgeInsets BMEdgeInsetsAdd(UIEdgeInsets insets1, UIEdgeInsets insets2);

/**
 * Returns the resulting edge insets by subtracting insets2 from insets1.
 */
UIEdgeInsets BMEdgeInsetsSubtract(UIEdgeInsets insets1, UIEdgeInsets insets2);

/**
 * Returns a UIEdgeInsets struct with the difference when subtracting rect2 from rect1
 */
UIEdgeInsets BMEdgeInsetsWithDiffFromRects(CGRect rect1, CGRect rect2);

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
+ (nullable NSBundle *)bundle;

@end

NS_ASSUME_NONNULL_END
