//
//  BMGoogleAuthenticationController.m
//  BMCommons
//
//  Created by Werner Altewischer on 23/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMGoogleAuthenticationController.h"
#import "GTMOAuth2SignIn.h"
#import "BMOAuth2ViewControllerTouch.h"
#import <BMGoogle/BMGoogle.h>
#import <BMUICore/BMBusyView.h>

@interface BMGoogleAuthenticationController()<BMBusyViewDelegate>

@end

@interface BMGoogleAuthenticationController(Private)

- (void)retrieveAuthenticationFromKeychain;
- (void)setAuthentication:(GTMOAuth2Authentication *)auth;

@end

@implementation BMGoogleAuthenticationController {
    UIViewController *__weak _parentViewController;
    GTMOAuth2Authentication *_authentication;
    BMOAuth2ViewControllerTouch *_signInViewController;
    BOOL _cancelled;
    BMBusyView *_busyView;
}

@synthesize scope, clientID, clientSecret, keychainItemName, delegate;
@synthesize parentViewController = _parentViewController, signInViewController = _signInViewController, cancelled = _cancelled;

- (id)init {
    if ((self = [super init])) {
        BMGoogleCheckLicense();
    }
    return self;
}

- (void)dealloc {
    delegate = nil;
    [self dismissWithCompletion:nil];
    BM_RELEASE_SAFELY(_authentication);
}

- (void)signInWithParentViewController:(UIViewController *)vc {
    
    [self retrieveAuthenticationFromKeychain];
    _cancelled = NO;
    
    if (!_authentication.canAuthorize) {
        
        if (_signInViewController == nil) {
        
            _parentViewController = vc;
            
            // Display the autentication view.
            _signInViewController = [BMOAuth2ViewControllerTouch controllerWithScope:self.scope
                                                                            clientID:self.clientID
                                                                        clientSecret:self.clientSecret
                                                                    keychainItemName:self.keychainItemName
                                                                            delegate:self
                                                                    finishedSelector:@selector(viewController:finishedWithAuth:error:)];
            
            // Optional: Google servers allow specification of the sign-in display
            // language as an additional "hl" parameter to the authorization URL,
            // using BCP 47 language codes.
            //
            // For this sample, we'll force English as the display language.
            NSDictionary *params = @{@"hl": @"en"};
            _signInViewController.signIn.additionalAuthorizationParameters = params;
            _signInViewController.signIn.shouldFetchGoogleUserEmail = NO;
            _signInViewController.signIn.shouldFetchGoogleUserProfile = NO;
            
            // Optional: display some html briefly before the sign-in page loads
            NSString *html = @"<html><body bgcolor=silver><div align=center>Loading Google sign-in page...</div></body></html>";
            _signInViewController.initialHTMLString = html;
            
            
            _signInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: BMUICoreLocalizedString(@"button.title.cancel", @"Cancel")
                                                                                                       style: UIBarButtonItemStyleBordered
                                                                                                      target: self
                                                                                                      action: @selector(cancel)];
            _signInViewController.title = BMLocalizedString(@"googleauthentication.title", @"Google Sign In");
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startedLoading:) name:kGTMOAuth2WebViewStartedLoading object:_signInViewController];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stoppedLoading:) name:kGTMOAuth2WebViewStoppedLoading object:_signInViewController];
            
            if ([self.delegate respondsToSelector:@selector(googleAuthenticationController:presentViewController:)]) {
                [self.delegate googleAuthenticationController:self presentViewController:_signInViewController];
            } else {
                [self presentAuthViewController:_signInViewController];
            }
        }
        
    } else {
        
        //Authentication not needed, already authorized
        [self.delegate googleAuthenticationController:self didFinishWithAuthentication:_authentication];
    }
    
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        LogError(@"Google Authentication error: %@", error);
        NSData *responseData = [error userInfo][@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding];
            LogError(@"Server's response: %@", str);
        }
        [self setAuthentication:nil];
        
        if (!self.isCancelled) {
            [self.delegate googleAuthenticationController:self didFailWithError:error];
        }
    } else {
        // save the authentication object
        [self setAuthentication:auth];
        
        [self.delegate googleAuthenticationController:self didFinishWithAuthentication:auth];
    }   
}

- (void)signOut {
    [self retrieveAuthenticationFromKeychain];
    
    if ([_authentication.serviceProvider isEqual:kGTMOAuth2ServiceProviderGoogle]) {
        // remove the token from Google's servers
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:_authentication];
    }
    
    // remove the stored Google authentication from the keychain, if any
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:self.keychainItemName];
    
    // Discard our retained authentication object.
    [self setAuthentication:nil];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    if ([self.delegate respondsToSelector:@selector(googleAuthenticationController:dismissViewController:withCompletion:)]) {
        [self.delegate googleAuthenticationController:self dismissViewController:_signInViewController withCompletion:completion];
    } else {
        [self dismissAuthViewController:_signInViewController withCompletion:completion];
    }
    
    if (_signInViewController) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        BM_RELEASE_SAFELY(_signInViewController);
    }
    if (_busyView) {
        [_busyView hideAnimated:YES];
        BM_RELEASE_SAFELY(_busyView);
    }
    _parentViewController = nil;
}

- (void)cancel {
    _cancelled = YES;
    [self dismissWithCompletion:nil];
    if ([self.delegate respondsToSelector:@selector(googleAuthenticationControllerWasCancelled:)] ) {
        [self.delegate googleAuthenticationControllerWasCancelled:self];
    }
}

- (BOOL)isAuthenticated {
    return self.authentication.canAuthorize;
}

- (GTMOAuth2Authentication *)authentication {
    if (!_authentication) {
        [self retrieveAuthenticationFromKeychain];
    }
    return _authentication;
}

#pragma mark - Notifications

- (void)startedLoading:(NSNotification *)notifcation {
    if (!_busyView) {
        _busyView = [[BMBusyView alloc] init];
        _busyView.delegate = self;
        _busyView.cancelEnabled = YES;
        [_busyView showAnimated:YES];
    }
}

- (void)stoppedLoading:(NSNotification *)notifcation {
    if (_busyView) {
        [_busyView hideAnimated:YES];
        BM_RELEASE_SAFELY(_busyView);
    }
}

#pragma mark - BMBusyViewDelegate

- (void)busyViewWasCancelled:(BMBusyView *)view {
    [_signInViewController cancelLoading];
}

@end

@implementation BMGoogleAuthenticationController(Protected)

- (void)presentAuthViewController:(GTMOAuth2ViewControllerTouch *)viewController {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.parentViewController presentViewController:navController animated:YES completion:nil];
}

- (void)dismissAuthViewController:(GTMOAuth2ViewControllerTouch *)viewController withCompletion:(void (^)(void))completion {
    [viewController.parentViewController dismissViewControllerAnimated:YES completion:completion];
}


@end

@implementation BMGoogleAuthenticationController(Private)

- (void)retrieveAuthenticationFromKeychain {
    self.authentication = nil;
    if (self.clientID && self.clientSecret && self.keychainItemName) {
        self.authentication = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:self.keychainItemName
                                                                                    clientID:self.clientID
                                                                                clientSecret:self.clientSecret];
    }
}

- (void)setAuthentication:(GTMOAuth2Authentication *)auth {
    if (auth != _authentication) {
        _authentication = auth;
    }
}

@end
