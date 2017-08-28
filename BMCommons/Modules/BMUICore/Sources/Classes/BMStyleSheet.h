//
//  BMStyleSheet.h
//  BMCommons
//
//  Created by Werner Altewischer.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMUICoreObject.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 UI style sheet.
 
 Stylesheets return common user interface elements used in views or view controllers.
 */
@interface BMStyleSheet : BMUICoreObject

/**
 The default stylesheet to be used.
 */
+ (instancetype)defaultStyleSheet;

/**
 Sets the default stylesheet.
 */
+ (void)setDefaultStyleSheet:(BMStyleSheet*)styleSheet;

/**
 Returns the top-most stylesheet of the stack or the default stylesheet as fallback.
 */
+ (instancetype)currentStyleSheet;

/**
 Push a stylesheet on the stack to make it current.
 */
+ (void)pushStyleSheet:(BMStyleSheet*)styleSheet;

/**
 Pops the top-most stylesheet from the stack.
 */
+ (void)popStyleSheet;

/**
 Frees any memory caches held
 */
- (void)freeMemory;

@end

@interface BMStyleSheet(BMNavigationController)

/**
 The default navigation bar style to use.
 */
- (UIBarStyle)navigationBarStyle;

/**
 The default navigation bar tint color to use. 
 
 This maps to tintColor on iOS < 7 and barTintColor >= 7.
 */
- (nullable UIColor *)navigationBarTintColor;

/**
 The tintColor (under iOS 7) for the navigation bar. 
 
 Doesn't have any effect on iOS < 7.
 */
- (nullable UIColor *)navigationBarTextTintColor;

/**
 The default translucency of navigation bar to use.
 */
- (BOOL)navigationBarTranslucent;

@end

/**
 Defaults used by BMTableViewController.
 */
@interface BMStyleSheet(BMTableViewController)

/**
 Default plain background color.
 */
- (nullable UIColor*)tableViewPlainBackgroundColor;

/**
 Default grouped background color.
 */
- (nullable UIColor*)tableViewGroupedBackgroundColor;

/**
 Default row height if non other is supplied.
 */
- (CGFloat)tableViewRowHeight;

/**
 Default separator style.
 */
- (UITableViewCellSeparatorStyle)tableViewSeparatorStyle;

/**
 Default separator color.
 */
- (nullable UIColor *)tableViewSeparatorColor;

/**
 The default background image for the table view.
 If this returns non-nil the background color of the tableview itself is set to [UIColor clearColor].
 */
- (nullable UIImage *)tableViewBackgroundImage;

/**
 The default background color for a tableview cell.
 */
- (nullable UIColor *)tableViewCellBackgroundColor;

@end

/**
 Default style for BMTableViewCells.
 */
@interface BMStyleSheet (BMTableViewCell)

/**
 Default cell selection style for sub classes of BMTableViewCell.
 */
- (UITableViewCellSelectionStyle)tableViewCellSelectionStyle;

/**
 Default BMTableViewCell text color.
 
 @see [UITableViewCell textLabel]
 */
- (nullable UIColor *)tableViewCellTextColor;

/**
 Default BMTableViewCell text font.
 
 @see [UITableViewCell textLabel]
 */
- (nullable UIFont *)tableViewCellTextFont;

/**
 Default BMTableViewCell detail text color.
 
 @see [UITableViewCell detailTextLabel]
 */
- (nullable UIColor *)tableViewCellDetailTextColor;

/**
 Default BMTableViewCell detail text font.
 
 @see [UITableViewCell detailTextLabel]
 */
- (nullable UIFont *)tableViewCellDetailTextFont;

@end

/**
 Style elements for the BMTableHeaderDragRefreshView and BMTableFooterDragLoadMoreView.
 */
@interface BMStyleSheet (BMDragRefreshHeader)

/**
 The font used for the last updated label.
 */
- (nullable UIFont*) tableRefreshHeaderLastUpdatedFont;

/**
 The font used for the status label.
 */
- (nullable UIFont*) tableRefreshHeaderStatusFont;

/**
 The background color used for the view.
 */
- (nullable UIColor*) tableRefreshHeaderBackgroundColor;

/**
 The text color used.
 */
- (nullable UIColor*) tableRefreshHeaderTextColor;

/**
 The shadow text color used.
 */
- (nullable UIColor*) tableRefreshHeaderTextShadowColor;

/**
 The shadow offset for the text.
 */
- (CGSize)   tableRefreshHeaderTextShadowOffset;

/**
 The arrow image used. 
 
 This image is rotated automatically by the view as needed.
 */
- (nullable UIImage*) tableRefreshHeaderArrowImage;

/**
 Sound to play when the user drags to refresh.
 */
- (nullable NSURL*)dragRefreshSoundFileURL;

/**
 The style to use for the activity indicator.
 */
- (UIActivityIndicatorViewStyle)tableRefreshHeaderActivityIndicatorStyle;

@end

/**
 Style elements used by BMBusyView (loading indicator).
 */
@interface BMStyleSheet (BMBusyView)

/**
 The background image for the send to background button.
 */
- (nullable UIImage *)busyViewSendToBackgroundButtonImage;

/**
 The text color for the cancel label of the busy view.
 */
- (nullable UIColor *)busyViewCancelLabelTextColor;

/**
 The text color for the title label of the busy view.
 */
- (nullable UIColor *)busyViewTitleLabelTextColor;

/**
 The background color for the busy view.
 */
- (nullable UIColor *)busyViewBackgroundColor;

/**
 The activity indicator style for the busy view.
 */
- (UIActivityIndicatorViewStyle)busyViewActivityIndicatorStyle;

@end

/**
 Style elements used by BMAsyncImageButton.
 */
@interface BMStyleSheet(BMAsyncImageButton)

/**
 The image to show when an async image button is loading or fails loading.
 */
- (nullable UIImage *)asyncImageButtonPlaceHolderImage;

@end

NS_ASSUME_NONNULL_END

