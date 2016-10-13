//
//  BMAppDelegate.m
//  BMCommons
//
//  Created by Werner Altewischer on 21/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAppDelegate.h>
#import <BMCommons/BMUICore.h>
#import <BMCommons/BMServiceManager.h>

@interface BMAppDelegate(Private)

- (void)showAlertForService:(id <BMService>)service withError:(NSError *)error;
- (void)pushForegroundService:(id <BMService>)service;
- (void)popForegroundService:(id <BMService>)service;
- (void)pushService:(id <BMService>)service;
- (void)popService:(id <BMService>)service;

@end


@implementation BMAppDelegate {
    UIWindow *_window;
	BMApplicationContext *_applicationContext;
    NSMutableDictionary *_activeForegroundServices;
    NSInteger _serviceCount;
}

@synthesize window = _window, applicationContext = _applicationContext;

#pragma mark -
#pragma mark Initialization and deallocation

+ (BMAppDelegate *)instance {
	return (BMAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (id)init {
	if ((self = [super init])) {
        _activeForegroundServices = [NSMutableDictionary new];
        _applicationContext = (BMApplicationContext *)[[self applicationContextClass] sharedInstance];
	}
	return self;
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
        
    [BMBusyView setDefaultInitBlock:^(BMBusyView *bv) {
        [self initBusyView:bv];
        bv.delegate = self;
    }];

    [[BMServiceManager sharedInstance] addServiceDelegate:self];
    
    // Override point for customization after application launch.
	[_applicationContext initialize];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	
	[_applicationContext deactivate];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	[_applicationContext activate];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	[_applicationContext terminate];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [_applicationContext clearCaches];
}

- (UIViewController *)rootViewController {
    return nil;
}

#pragma mark - Protected methods

- (void)shakeDetected {
    
}

- (Class)applicationContextClass {
    return [BMApplicationContext class];
}

- (void)initBusyView:(BMBusyView *)theBusyView {
    
}

#pragma mark -
#pragma mark BMServiceDelegate implementation

- (void)serviceDidStart:(id <BMService>)service {
    //Push the service on the stack: will show busy view
    [self pushService:service];
}

/**
 * Implement to act on successful completion of a service.
 */
- (void)service:(id <BMService>)service succeededWithResult:(id)result {
    //Pop the service from the stack
    [self popService:service];
}

- (void)service:(id <BMService>)service updatedProgress:(double)progressPercentage withMessage:(NSString *)message {
    if (!service.isBackgroundService) {
        //Update the busy view progress and message
        [self updateBusyViewWithMessage:message andProgress:progressPercentage];
    }
}

/**
 * Implement to act on failure of a service.
 */
- (void)service:(id <BMService>)service failedWithError:(NSError *)error {
    [self popService:service];
    
    //Show an error alert in a generic way
    [self showAlertForService:service withError:error];
}

- (void)serviceWasCancelled:(id <BMService>)service {
    [self popService:service];
}

- (void)serviceWasSentToBackground:(id<BMService>)service {
    [self popForegroundService:service];
}

#pragma mark -
#pragma mark BMBusyViewDelegate

//The code below ties the busyview actions to the service manager, such as cancellation, send to background, etc.

- (void)busyViewWasCancelled:(BMBusyView *)theBusyView {
    //Handle cancellation of services in one place
    theBusyView.label.text = BMLocalizedString(@"busyview.title.cancelling", @"Cancelling...");
    for (NSString *identifier in [NSArray arrayWithArray:[_activeForegroundServices allKeys]]) {
        BOOL isCancellable = [_activeForegroundServices[identifier] boolValue];
        //Cancel the service if allowed
        if (isCancellable) {
            [[BMServiceManager sharedInstance] cancelServiceWithInstanceIdentifier:identifier];
        }
    }
}

- (void)busyViewWasSentToBackground:(BMBusyView *)theBusyView {
    //Handle sending to background
    theBusyView.label.text = BMLocalizedString(@"busyview.title.sendingtobackground", @"Sending to background...");
    for (NSString *identifier in [NSArray arrayWithArray:[_activeForegroundServices allKeys]]) {
        [[BMServiceManager sharedInstance] sendServiceToBackgroundWithInstanceIdentifier:identifier];
    }
}

#pragma mark - Protected methods

- (void)showError:(NSError *)error forService:(id <BMService>)service {
    
}

- (void)updateBusyViewWithMessage:(NSString *)message andProgress:(CGFloat)progressPercentage {
    [BMBusyView showBusyViewWithMessage:message andProgress:progressPercentage];
}

- (void)showBusyViewWithCancelEnabled:(BOOL)cancelEnabled backgroundEnabled:(BOOL)backgroundEnabled {
    //Configure the busy view
    BMBusyView *bv = [BMBusyView sharedBusyView];
    if (!bv) {
        bv = [BMBusyView showBusyViewAnimated:YES cancelEnabled:cancelEnabled];
    }
    bv.sendToBackgroundEnabled = backgroundEnabled;
    bv.cancelEnabled = cancelEnabled;
    bv.delegate = self;
}

- (void)hideBusyView {
    [BMBusyView hideBusyView];
}

@end

@implementation BMAppDelegate(Private)

- (void)showAlertForService:(id <BMService>)service withError:(NSError *)error {
    //Show alert on error
    //LogWarn is defined in BMLogging.h
    LogWarn(@"Service: %@ failed with error: %@", service, error);
    if (!service.isBackgroundService && !service.isErrorHandled) {
        //NSLocalizedString is redefined in BMLocalization such that the second parameter is the default value
        [self showError:error forService:service];
    }
}

- (void)pushForegroundService:(id <BMService>)service {
    //Keep track of whether cancel button should be enabled or not. Only for services that are cancellable by the user
    _activeForegroundServices[service.instanceIdentifier] = @(service.isUserCancellable);
    BOOL cancelEnabled = YES;
    for (id key in _activeForegroundServices) {
        NSNumber *n = _activeForegroundServices[key];
        cancelEnabled = cancelEnabled && [n boolValue];
    }
    
    [self showBusyViewWithCancelEnabled:cancelEnabled backgroundEnabled:service.isSendToBackgroundSupported];
    
    //Disable the idle timer of the app, thereby preventing it to go on standby
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)popForegroundService:(id <BMService>)service {
    //Pop the foreground service
    [_activeForegroundServices removeObjectForKey:service.instanceIdentifier];
    if (_activeForegroundServices.count == 0) {
        //If no active foreground services are present anymore: hide the busy view
        [self hideBusyView];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
}

- (void)pushService:(id <BMService>)service {
    if (!service.isBackgroundService) {
        [self pushForegroundService:service];
    }
    _serviceCount++;
}

- (void)popService:(id <BMService>)service {
    if (service) {
        if (!service.isBackgroundService) {
            [self popForegroundService:service];
        }
        _serviceCount--;
    }
}

@end
