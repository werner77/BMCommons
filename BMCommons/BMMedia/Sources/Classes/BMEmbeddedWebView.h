//
//  BMEmbeddedWebView.h
//  BMCommons
//
//  Created by Werner Altewischer on 24/09/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 View containing a webView, a placeholderImage, support for loadingImage and errorImage and an activity indicator.
 */
@interface BMEmbeddedWebView : UIView

/**
 The url to load from.
 */
@property (nonatomic, strong) NSString *url;

/**
 Returns YES if the webview needs (re)loading.
 
 Reload (by a call to startLoading) will happen automatically the next time layoutSubviews is called.
 */
@property (nonatomic, readonly) BOOL needsLoading;

/**
 Image view containing a placeholder image in case no content is present.
 
 @see loadingImage
 @see errorImage
 */
@property (strong, nonatomic, readonly) UIImageView *placeHolderView;

/**
 Web view for showing the web content.
 */
@property (strong, nonatomic, readonly) UIWebView *webView;

/**
 Image to display in the placeHolderView when the webview is loading.
 
 The default image is retrieved from the active BMStyleSheet.
 */
@property (nonatomic, strong) UIImage *loadingImage;

/**
 Image to display in the placeHolderView when the webview is in error.
 
 The default image is retrieved from the active BMStyleSheet.
 
 @see [BMStyleSheet webViewLoadingImage]
 @see [BMStyleSheet webViewErrorImage]
 */
@property (nonatomic, strong) UIImage *errorImage;

/**
 Whether or not to display an activity indicator when loading.
 
 Default is YES.
 */
@property (nonatomic, assign) BOOL showActivity;

/**
 A reference to the activity indicator.
 */
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

/**
 Force start loading of the webview. 
 
 This is called automatically if needsLoading returns YES and layoutSubview is called, which will always happen when the url changes.
 */
- (void)startLoading;

/**
 Stops or cancels loading.
 */
- (void)stopLoading;

/**
 Whether or not the webview succesfully loaded its content.
 */
- (BOOL)isLoaded;

@end

/**
 Protected methods for use by subclasses.
 */
@interface BMEmbeddedWebView(Protected)

- (void)prepareLoadingWithPlaceHolder:(BOOL)showPlaceholder;
- (void)setNeedsLoading;

@end
