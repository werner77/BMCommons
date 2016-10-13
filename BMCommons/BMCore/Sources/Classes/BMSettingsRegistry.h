//
//  BMSettingsRegistry.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/28/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMSettingsObject.h"
#import <BMCore/BMCoreObject.h>

/**
 Class that manages loading/saving settings objects (implementations of BMSettingsObject).
 */
@interface BMSettingsRegistry : BMCoreObject {
    @private
	NSDictionary *_settingsObjects;
    BOOL _loaded;
}

@property (nonatomic, strong) NSDictionary *settingsObjects;
@property (nonatomic, readonly, getter = isLoaded) BOOL loaded;

/**
 Initializes with settings object classes to register (implementations of BMSettingsObject). 
 
 It registers the objects by calling [BMSettingsObject sharedInstance] on the classes supplied.
 */
- (id)initWithClasses:(NSArray *)classes;

/**
 Saves the state of all managed settings objects to NSUserDefaults.
 */
- (void)save;

/**
 * Settings are synchronized to disk automatically at regular time interval and at application termination.
 * To synchronize manually call this method.
 */
- (void)synchronize;

/**
 Loads the state of all managed settings objects from NSUserDefaults.
 */
- (void)load;
- (NSObject <BMSettingsObject> *)settingsObjectForClass:(Class)clazz;

/**
 Restores the state of all managed settings objects to default (if they are allowed to be restored to defaults, see BMSettingsObject protocol).
 */
- (void)restoreToDefaults;

/**
 String identifying the version of the app
 */
- (NSString *)currentVersion;

/**
 Check to see if this is the first run ever of the app.
 
 After finishedInitialization is called this method always returns false.
 */
- (BOOL)isFirstRun;

/**
 Check to see if this is the first run for the current version.
 
 After finishedInitialization is called this method always returns false.
 */
- (BOOL)isFirstRunForCurrentVersion;

/**
 Call this method when initialization has finished: it will reset the firstRun and firstRunForCurrentVersion flags.
 */
- (void)finishedInitialization;
	

@end
