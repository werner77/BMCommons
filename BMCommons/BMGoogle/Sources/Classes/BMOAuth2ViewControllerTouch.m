//
//  BMOAuth2ViewControllerTouch.m
//  BMCommons
//
//  Created by Werner Altewischer on 24/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMOAuth2ViewControllerTouch.h>
#import <BMCommons/BMGoogle.h>

@interface GTMOAuth2ViewControllerTouch()

- (void)moveWebViewFromUnderNavigationBar;

@end

@implementation BMOAuth2ViewControllerTouch

+ (NSBundle *)authNibBundle {
    return [BMGoogle bundle];
}

+ (NSString *)authNibName {
    // subclasses may override this to specify a custom nib name
    return @"BMOAuth2ViewTouch";
}

- (void)cancelLoading {
    UIWebView *webView = [self webView];
    [webView stopLoading];
}

- (void)moveWebViewFromUnderNavigationBar {
    if (!BMOSVersionIsAtLeast(@"7.0")) {
        [super moveWebViewFromUnderNavigationBar];
    }
}

@end
