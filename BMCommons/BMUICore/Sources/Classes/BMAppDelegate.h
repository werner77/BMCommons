//
//  BMAppDelegate.h
//  BMCommons
//
//  Created by Werner Altewischer on 21/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMApplicationContext.h>
#import <BMUICore/BMBusyView.h>
#import <BMUICore/BMUICoreObject.h>

/**
 Base class for UIApplicationDelegate implementations.
 
 This class ensures the proper methods of BMApplicationContext are called on life-cycle events and has support for showing a global busy view (loading view) when services (instances of BMService) are active.
 
 @see BMApplicationContext
 @see BMBusyView
 @see BMService
 */
@interface BMAppDelegate : BMUICoreObject <UIApplicationDelegate, BMBusyViewDelegate, BMServiceDelegate>

/**
 Application window.
 */
@property (nonatomic, strong) IBOutlet UIWindow *window;

/**
 Whether or not to automatically manage the showing/hiding of a BMBusyView on BMService activity.
 
 Default is YES. For background services no busy view is shown.
 */
@property (nonatomic, assign) BOOL showBusyViewOnServiceActivity;

@property (nonatomic, readonly) BMApplicationContext *applicationContext;

/**
 The one and only instance of this app delegate.
 */
+ (BMAppDelegate *)instance;

/**
 The root viewcontroller for this application.
 */
- (UIViewController *)rootViewController;

@end

@interface BMAppDelegate(Protected)

/**
 The implementation class of the application context for this application.
 */
- (Class)applicationContextClass;

/**
 Override to perform custom initialization on the busy view to show on service activity.
 */
- (void)initBusyView:(BMBusyView *)theBusyView;

/**
 Override to handle a service error.
 
 This is only called if the [BMService isErrorHandled] property returns NO.
 */
- (void)showError:(NSError *)error forService:(id <BMService>)service;

/**
 Shows a busy view.
 */
- (void)showBusyViewWithCancelEnabled:(BOOL)cancelEnabled backgroundEnabled:(BOOL)backgroundEnabled;

/**
 Updates a shown busy view.
 */
- (void)updateBusyViewWithMessage:(NSString *)message andProgress:(CGFloat)progressPercentage;

/**
 Hides the busy view.
 */
- (void)hideBusyView;

@end
