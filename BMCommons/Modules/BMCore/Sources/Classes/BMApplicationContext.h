//
//  BMApplicationContext.h
//  BehindMedia
//
//  Created by Werner Altewischer on 28/08/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMServiceManager.h>
#import <BMCommons/BMCoreObject.h>
#import <BMCommons/BMSettingsRegistry.h>
#import <BMCommons/BMOperationQueue.h>

NS_ASSUME_NONNULL_BEGIN

@class BMApplicationContext;

/**
 Delegate protocol for BMApplicationContext, to be implemented by classes that want to be notified of application context events.
 */
@protocol BMApplicationContextDelegate<NSObject>

@optional

/**
 Sent when the application finished initialization, sent when delayedInitialization completes.
 */
- (void)applicationContextDidInitialize:(BMApplicationContext *)applicationContext;

@end


/**
 Registry for application singletons and settings and coordinator for application life-cycle events.
 */
@interface BMApplicationContext : BMCoreObject

BM_DECLARE_DEFAULT_SINGLETON

/**
 Operation queue to perform async operations.
 */
@property (nonatomic, readonly) BMOperationQueue *operationQueue;

/**
 Service manager to use for executing BMService implementations.
 */
@property(nonatomic, readonly) BMServiceManager *serviceManager;

/**
Settings registry that manages registered instances of BMSettingsObject.
*/
@property(nonatomic, readonly) BMSettingsRegistry *settings;

/**
 True if the application is active (after initialization has completed), false otherwise.
 */
@property(nonatomic, assign, getter=isActive) BOOL active;

/**
 Dictionary containing all environment variables (including system environment).
 */
@property (strong, nonatomic, readonly) NSDictionary *environment;

/**
 Method to be called on first initialization of the application (applicationDidFinishLoading)
 */
- (void)initialize;

/**
 Method to be called on activation of the application (applicationDidBecomeActive).
 */
- (void)activate;

/**
 Method to be called on deactivation of the application (applicationWillResignActive).
 */
- (void)deactivate;

/**
 Saves settings and any other state that needs to be saved.
 
 Sub-classes should override this if additional state is to be saved.
 */
- (void)save;

/**
 Loads the settings
 */
- (void)loadSettings;

/**
 Saves settings.
 */
- (void)saveSettings;

/**
 Method to be called on termination of the application (applicationWillTerminate)
 */
- (void)terminate;

/**
 Clears in-memory caches.
 */
- (void)clearCaches;

/**
 Version number of the app
 */
- (NSString *)appVersion;

/**
 Build numer of the app
 */
- (NSString *)appBuild;

/**
 String in format "${app_version} build ${app_build}"
 */
- (NSString *)fullAppVersion;

/**
Returns the array of registered delegates, implementations of BMApplicationContextDelegate.
*/
- (NSArray *)delegates;

/**
 Adds a BMApplicationContextDelegate implementation as listener.
 */
- (void)addDelegate:(id <BMApplicationContextDelegate>)delegate;

/**
 Adds a BMApplicationContextDelegate implementation as listener which is notified before other delegates.
 */
- (void)addPriorityDelegate:(id <BMApplicationContextDelegate>)delegate;

/**
 Removes a BMApplicationContextDelegate implementation as listener.
 */
- (void)removeDelegate:(id <BMApplicationContextDelegate>)delegate;

/**
 Registers a global environment variable
 */
- (void)setObject:(id)object forEnvironmentVariable:(NSString *)variable;

/**
 Gets a global environment variable
 */
- (id)objectForEnvironmentVariable:(NSString *)variable;

@end

@interface BMApplicationContext(Protected)

/**
 Should return an array of classes implementing the BMSettingsObject protocol.
 
 These classes are added to the settings registry for synchronization with NSUserDefaults.
 */
- (NSArray *)settingsObjectClasses;

/**
 Starts the listining for notifications from NSNotificationCenter. 
 
 This method is invoked at the end of initialize.
 */
- (void)startListeningForNotifications;

/**
 Stops the listining for notifications from NSNotificationCenter.
 
 This method is invoked at termination.
 */
- (void)stopListeningForNotifications;

/**
 Initialization that should be performed asynchronously, after normal initialization has finished and the app is already active. 
 
 Examples are synchronizing some data from a server in the background.
 */
- (void)delayedInitialization;


@end

NS_ASSUME_NONNULL_END