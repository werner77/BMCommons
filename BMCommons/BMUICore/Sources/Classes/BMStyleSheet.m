//
//  BMStyleSheet.m
//  BMCommons
//
//  Created by Werner Altewischer.
//  Copyright 2011 BehindMedia. All rights reserved.
//


#import "BMStyleSheet.h"
#import "BMURLCache.h"
#import <BMCommons/BMUICore.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMStyleSheet

static BMStyleSheet *gStyleSheet = nil;
static NSMutableArray *styleSheetStack = nil;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(didReceiveMemoryWarning:)
         name:UIApplicationDidReceiveMemoryWarningNotification
         object:nil];
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationDidReceiveMemoryWarningNotification
     object:nil];
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype)defaultStyleSheet {
    if (!gStyleSheet) {
        gStyleSheet = [[BMStyleSheet alloc] init];
    }
    return gStyleSheet;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setDefaultStyleSheet:(BMStyleSheet *)styleSheet {
    gStyleSheet = styleSheet;
}

+ (void)pushStyleSheet:(BMStyleSheet *)styleSheet {
    if (!styleSheetStack) {
        styleSheetStack = [NSMutableArray new];
    }
    [styleSheetStack addObject:styleSheet];
}

+ (void)popStyleSheet {
    if (styleSheetStack.count > 0) {
        [styleSheetStack removeLastObject];
    }
}

+ (instancetype)currentStyleSheet {
    BMStyleSheet *currentStyleSheet = [styleSheetStack lastObject];
    if (!currentStyleSheet) {
        currentStyleSheet = [self defaultStyleSheet];
    }
    return currentStyleSheet;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSNotifications


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning:(void *)object {
    [self freeMemory];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)freeMemory {
}


@end

@implementation BMStyleSheet(BMNavigationController)

- (UIBarStyle)navigationBarStyle {
    return UIBarStyleDefault;
}

- (UIColor *)navigationBarTintColor {
    return nil;
}

- (UIColor *)navigationBarTextTintColor {
    return nil;
}


- (BOOL)navigationBarTranslucent {
    return NO;
}

@end

@implementation BMStyleSheet(BMTableViewController)


- (UIColor*)tableViewPlainBackgroundColor {
    return nil;
}

- (UIColor*)tableViewGroupedBackgroundColor {
    return nil;
}

/**
 Default row height if non other is supplied.
 */
- (CGFloat)tableViewRowHeight {
    return BM_ROW_HEIGHT;
}

- (UITableViewCellSeparatorStyle)tableViewSeparatorStyle {
    return UITableViewCellSeparatorStyleSingleLine;
}

/**
 Default separator color.
 */
- (UIColor *)tableViewSeparatorColor {
    return nil;
}

- (UIImage *)tableViewBackgroundImage {
    return nil;
}

- (UIColor *)tableViewCellBackgroundColor {
    return nil;
}

@end

@implementation BMStyleSheet(BMTableViewCell)

- (UITableViewCellSelectionStyle)tableViewCellSelectionStyle {
    return UITableViewCellSelectionStyleBlue;
}

- (UIColor *)tableViewCellTextColor {
    return nil;
}

- (UIFont *)tableViewCellTextFont {
    return nil;
}

- (UIColor *)tableViewCellDetailTextColor {
    return nil;
}

- (UIFont *)tableViewCellDetailTextFont {
    return nil;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMStyleSheet (BMDragRefreshHeader)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableRefreshHeaderLastUpdatedFont {
  return [UIFont systemFontOfSize:12.0f];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableRefreshHeaderStatusFont {
  return [UIFont boldSystemFontOfSize:14.0f];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableRefreshHeaderBackgroundColor {
  return BMRGBCOLOR(226, 231, 237);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableRefreshHeaderTextColor {
  return BMRGBCOLOR(109, 128, 153);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableRefreshHeaderTextShadowColor {
  return [[UIColor whiteColor] colorWithAlphaComponent:0.9];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)tableRefreshHeaderTextShadowOffset {
  return CGSizeMake(0.0f, 1.0f);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)tableRefreshHeaderArrowImage {
  return BMIMAGE(@"bundle://BMUICore.bundle/blueArrow.png");
}

- (UIActivityIndicatorViewStyle)tableRefreshHeaderActivityIndicatorStyle {
    return UIActivityIndicatorViewStyleWhite;
}

- (NSURL*)dragRefreshSoundFileURL {
    return nil;
}

@end

@implementation BMStyleSheet(BMBusyView)

- (UIImage *)busyViewSendToBackgroundButtonImage {
    return BMIMAGE(@"bundle://BMUICore.bundle/buttonGray.png");
}

- (UIColor *)busyViewCancelLabelTextColor {
    return [UIColor grayColor];
}

- (UIColor *)busyViewTitleLabelTextColor {
    return  [UIColor whiteColor];
}

- (UIColor *)busyViewBackgroundColor {
    return [UIColor darkTextColor];
}

- (UIActivityIndicatorViewStyle)busyViewActivityIndicatorStyle {
    return UIActivityIndicatorViewStyleWhite;
}

@end

@implementation BMStyleSheet(BMAsyncImageButton)

- (UIImage *)asyncImageButtonPlaceHolderImage {
    return BMIMAGE(@"bundle://BMUICore.bundle/default-no-image-small.png");
}

@end

