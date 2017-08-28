//
//  UIWebView+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 01/11/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWebView(BMCommons)

/**
  * Sets the userinteraction, scrolling, zooming and background/transparency such that the web view is in non-interactive, label mode.
 
  * Use this to get a web view which acts as a kind of rich text format label.
  */
- (void)bmApplyRTFLabelTemplate;

/**
  Loads an HTML resource with the specified name from the main bundle, assuming the directory in which this file resides as base dir. 
 
 Assumes ".html" extension.
  */
- (void)bmLoadHTMLResourceWithName:(NSString *)htmlResourceName;

/**
 Loads an HTML resource with the specified name for the specified locale.
 
 @see [NSBundle pathForResource:ofType:inDirectory:forLocalization:]
 */
- (void)bmLoadHTMLResourceWithName:(NSString *)htmlResourceName forLocalization:(nullable NSString *)localizationName;

@end

NS_ASSUME_NONNULL_END
