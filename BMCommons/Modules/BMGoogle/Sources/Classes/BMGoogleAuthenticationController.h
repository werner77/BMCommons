//
//  BMGoogleAuthenticationController.h
//  BMCommons
//
//  Created by Werner Altewischer on 23/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GTMOAuth2/GTMOAuth2ViewControllerTouch.h>
#import <GTMOAuth2/GTMOAuth2Authentication.h>

@class BMGoogleAuthenticationController;

@protocol BMGoogleAuthenticationControllerDelegate <NSObject>

- (void)googleAuthenticationController:(BMGoogleAuthenticationController *)controller didFinishWithAuthentication:(GTMOAuth2Authentication *)authentication;
- (void)googleAuthenticationController:(BMGoogleAuthenticationController *)controller didFailWithError:(NSError *)error;

@optional

/**
 Implement this method to perform customization on the Google OAuth view controller and the way it will be displayed. 
 
 By default it is wrapped in a UINavigationController and presented modally.
 */
- (void)googleAuthenticationController:(BMGoogleAuthenticationController *)controller presentViewController:(GTMOAuth2ViewControllerTouch *)viewController;
- (void)googleAuthenticationController:(BMGoogleAuthenticationController *)controller dismissViewController:(GTMOAuth2ViewControllerTouch *)viewController withCompletion:(void (^)(void))completion;
- (void)googleAuthenticationControllerWasCancelled:(BMGoogleAuthenticationController *)controller;

@end

/**
 Use this class to present a Google login view if necessary.
 */
@interface BMGoogleAuthenticationController : NSObject

/**
 The google authorization scope. See Google documentation.
 */
@property (nonatomic, strong) NSString *scope;

/**
 The clientID of the application to authenticate with google
 */
@property (nonatomic, strong) NSString *clientID;

/**
 The clientSecret of the application to authenticate with google
 */
@property (nonatomic, strong) NSString *clientSecret;

/**
 The name of the keychain item to store the credentials
 */
@property (nonatomic, strong) NSString *keychainItemName;

/**
 Reference to the parent view controller from which the authentication controller was displayed.
 */
@property (weak, nonatomic, readonly) UIViewController *parentViewController;

/**
 Returns a reference to the sign in view controller if it is shown.
 */
@property (nonatomic, readonly) GTMOAuth2ViewControllerTouch *signInViewController;

/**
 Returns true iff the login process was cancelled.
 */
@property (nonatomic, readonly, getter = isCancelled) BOOL cancelled;

/**
 The delegate
 */
@property (nonatomic, weak) id <BMGoogleAuthenticationControllerDelegate> delegate;

/**
 Checks the keychain if sign in is necessary, if so it will show the Google oauth view controller by calling presentAuthViewController,
 else it will retrieve the authentication from the keychain and present it to the delegate.
 */
- (void)signInWithParentViewController:(UIViewController *)vc;

/**
 Signs the user out from Google.
 */
- (void)signOut;

/**
 Dismisses the Google oauth view controller if it is present.
 */
- (void)dismissWithCompletion:(void (^)(void))completion;

/**
 Sets the cancelled boolean to true and dismisses the view controller if present. 
 
 Delegates can check this boolean if the error occured due to
 manual cancellation by the user. 
 */
- (void)cancel;

/**
 Returns true if the user can be authenticated from the keychain (no need to show the login view controller).
 
 
 The - (GTMOAuth2Authentication *)authentication; method will return a non-nil authentication object in that case.
 */
- (BOOL)isAuthenticated;

/**
 Returns the current authentication object if authenticated.
 */
- (GTMOAuth2Authentication *)authentication;

@end

@interface BMGoogleAuthenticationController(Protected)

/**
 Implementation of the presenting of the actual login view controller. 
 
 By default wraps it in a UINavigationController and shows the latter
 modally. The navigation controller shows a cancel button as left bar button item which is bound to the cancel method.
 */
- (void)presentAuthViewController:(GTMOAuth2ViewControllerTouch *)viewController;

- (void)dismissAuthViewController:(GTMOAuth2ViewControllerTouch *)viewController withCompletion:(void (^)(void))completion;

@end
