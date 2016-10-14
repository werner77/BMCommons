//
//  SettingsObject.h
//  BehindMedia
//
//  Created by Werner Altewischer on 5/30/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Protocol for objects the should map to NSUserDefaults for storing their state.
 */
@protocol BMSettingsObject 

/**
 Returns a dictionary of key=<key in NSUserDefaults> and value=<default value> for the settings managed by the implementation of this protocol.
 */
+ (NSDictionary *)defaultValues;

/**
 Returns the one and only instance of this settings object.
 */
+ (instancetype)sharedInstance;

/**
 Whether the settings stored in this settings object are allowed to be restored to defaults. 
 
 For some properties this is not desired (e.g. for username/passwords
which would logout the user).
 */
+ (BOOL)allowRestoreToDefaults;

/**
 Method that stores the state of this settings object in NSUserDefaults.
 */
- (void)saveStateInUserDefaults:(NSUserDefaults *)defaults;

/**
 Method that loads the state of this settings object from NSUserDefaults.
 */
- (void)loadStateFromUserDefaults:(NSUserDefaults *)defaults;

/**
 Resets the settings to the default values. 
 
 Is called after the application was removed and started up for the first time to also allow deletion of items stored in
the keychain.
 */
- (void)reset;

@end

/**
 Protocol for objects that are initializable using a settings object (implementation of BMSettingsObject).
 */
@protocol BMSettingsInitializable

+ (id <BMSettingsObject, NSObject>)settings;
- (id)initFromSettings:(id <BMSettingsObject, NSObject>)settings;

@end
