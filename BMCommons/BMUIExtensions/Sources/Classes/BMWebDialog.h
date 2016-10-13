//
//  BMWebDialogDialog.h
//  BMCommons
//
//  Created by Werner Altewischer on 05/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BMWebDialogDelegate;

//The following 'magic' URLs can be used to dismiss the web dialog with success or failure (cancel). Use these as redirect urls and the WebDialog will automatically dismiss and send the
//right message to the delegate.

#define BM_WEBDIALOG_SCHEME @"webdialog"
#define BM_WEBDIALOG_SUCCESS_RESOURCE_IDENTIFIER @"success"
#define BM_WEBDIALOG_CANCEL_RESOURCE_IDENTIFIER @"cancel"

#define BM_WEBDIALOG_SUCCESS_URL BM_WEBDIALOG_SCHEME @"://" BM_WEBDIALOG_SUCCESS_RESOURCE_IDENTIFIER
#define BM_WEBDIALOG_CANCEL_URL BM_WEBDIALOG_SCHEME @"://" BM_WEBDIALOG_CANCEL_RESOURCE_IDENTIFIER

/**
 A web view dialog for displaying a rich text dialog in HTML with support for success and cancel callbacks using URLs.
 
 Use webdialog://success for success and webdialog://cancel for cancel.
 */
@interface BMWebDialog : UIView

/**
 * Delegate which implements BMWebDialogDelegate
 */
@property(nonatomic,weak) id<BMWebDialogDelegate> delegate;

/**
 * The title that is shown in the header at the top of the view;
 */
@property(nonatomic,copy) NSString* title;

/**
 * Creates the view but does not display it.
 */
- (id)initWithTitle:(NSString *)theTitle;

/**
 * Displays the view with an animation.
 *
 * The view will be added to the top of the current key window.
 */
- (void)show;

/**
 * Displays the first page of the dialog.
 *
 * Do not ever call this directly.  It is intended to be overriden by subclasses.
 */
- (void)load;

/**
 * Loads a URL request in the dialog.
 */
- (void)loadRequest:(NSURLRequest *)request;

/**
 * Hides the view and notifies delegates of success or cancellation.
 */
- (void)dismissWithSuccess:(BOOL)success animated:(BOOL)animated;

/**
 * Hides the view and notifies delegates of an error.
 */
- (void)dismissWithError:(NSError*)error animated:(BOOL)animated;

/**
 * Subclasses may override to perform actions just prior to showing the dialog.
 */
- (void)dialogWillAppear;

/**
 * Subclasses may override to perform actions just after the dialog is hidden.
 */
- (void)dialogWillDisappear;

/**
 * Subclasses should override to process data returned from the server in a 'fbconnect' url.
 *
 * Implementations must call dismissWithSuccess:YES at some point to hide the dialog.
 */
- (void)dialogDidSucceed:(NSURL*)url;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 Delegate protocol for BMWebDialog.
 */
@protocol BMWebDialogDelegate <NSObject>

@optional

/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidSucceed:(BMWebDialog*)dialog;

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidCancel:(BMWebDialog*)dialog;

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(BMWebDialog*)dialog didFailWithError:(NSError*)error;

/**
 * Asks if a link touched by a user should be opened in an external browser.
 *
 * If a user touches a link, the default behavior is to open the link in the Safari browser, 
 * which will cause your app to quit.  You may want to prevent this from happening, open the link
 * in your own internal browser, or perhaps warn the user that they are about to leave your app.
 * If so, implement this method on your delegate and return NO.  If you warn the user, you
 * should hold onto the URL and once you have received their acknowledgement open the URL yourself
 * using [[UIApplication sharedApplication] openURL:].
 */
- (BOOL)dialog:(BMWebDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL*)url;

@end
