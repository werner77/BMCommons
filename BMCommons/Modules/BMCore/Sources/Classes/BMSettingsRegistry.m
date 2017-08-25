//
//  BMSettingsRegistry.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/28/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMSettingsRegistry.h>
#import <BMCommons/BMApp.h>

@interface BMSettingsRegistry()

@property (nonatomic, strong) NSDictionary *settingsObjects;

@end

@interface BMSettingsRegistry(Private)

- (NSDictionary *)allDefaultSettings:(BOOL)excludeNilValues excludedNonRestorable:(BOOL)excludeNonRestorable;
- (NSString *)firstRunKey;
- (NSString *)currentVersionKey;

@end


@implementation BMSettingsRegistry {
@private
	NSDictionary *_settingsObjects;
	BOOL _loaded;
}

@synthesize settingsObjects = _settingsObjects, loaded = _loaded;

- (id)initWithClasses:(NSArray *)classes {
	if ((self = [super init])) {
		NSMutableArray *objects = [NSMutableArray array];
		for (Class clazz in classes) {
			NSObject <BMSettingsObject> *tempObj = (NSObject<BMSettingsObject> *)[clazz sharedInstance];
			[objects addObject:tempObj];
		}
		self.settingsObjects = [[NSDictionary alloc] initWithObjects:objects forKeys:classes];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *defaultSettings = [self allDefaultSettings:YES excludedNonRestorable:NO];
		[defaults registerDefaults:defaultSettings];
	}
	return self;
}

- (void)loadByForcingReset:(BOOL)forceReset {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL shouldReset = forceReset || self.isFirstRun;

	//Lets first synchronyze with the device, the user might have changed settings via 'User Preferences' of the device
	[defaults synchronize];

	NSEnumerator *enumerator = [_settingsObjects objectEnumerator];
	id <BMSettingsObject> object;
	while ((object = [enumerator nextObject])) {
		if (shouldReset) {
			[object reset];
		}
		[object loadStateFromUserDefaults:defaults];
	}
	_loaded = YES;
}

- (void)load {
	[self loadByForcingReset:NO];
}

- (void)save {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSEnumerator *enumerator = [_settingsObjects objectEnumerator];
	id <BMSettingsObject> object;
	while ((object = [enumerator nextObject])) {
		[object saveStateInUserDefaults:defaults];
	}
	[defaults synchronize];
}

- (BOOL)isFirstRun {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *n = [defaults objectForKey:self.firstRunKey];
	return n == nil || [n boolValue];
}

- (BOOL)isFirstRunForCurrentVersion {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return ![self.currentVersion isEqual:[defaults objectForKey:self.currentVersionKey]];
}

- (NSString *)currentVersion {
	return [[BMApp sharedInstance] version];
}

- (void)finishedInitialization {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSNumber numberWithBool:NO] forKey:self.firstRunKey];
	[defaults setObject:self.currentVersion forKey:self.currentVersionKey];
}

- (void)synchronize {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
}

- (NSObject <BMSettingsObject>*)settingsObjectForClass:(Class)clazz {
	return [_settingsObjects objectForKey:clazz];
}

- (void)restoreToDefaultsByForcingReset:(BOOL)forceReset {
	[self save];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *allDefaultSettings = [self allDefaultSettings:NO excludedNonRestorable:!forceReset];
	for (NSString *key in allDefaultSettings) {
		id value = [allDefaultSettings objectForKey:key];
		if ([NSNull null] != value) {
			[defaults setObject:value forKey:key];
		} else {
			[defaults removeObjectForKey:key];
		}
	}
	[self loadByForcingReset:forceReset];
}

- (void)restoreToDefaults {
	[self restoreToDefaultsByForcingReset:NO];
}

@end

@implementation BMSettingsRegistry(Private)

- (NSString *)firstRunKey {
	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	return [NSString stringWithFormat:@"%@_FIRSTRUN", bundleIdentifier];
}

- (NSString *)currentVersionKey {
	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	return [NSString stringWithFormat:@"%@_VERSION", bundleIdentifier];
}

- (NSDictionary *)allDefaultSettings:(BOOL)excludeNilValues excludedNonRestorable:(BOOL)excludeNonRestorable {
	NSMutableDictionary *appDefaults = [NSMutableDictionary dictionary];
	for (Class settingsObjectClass in self.settingsObjects) {
		if (!excludeNonRestorable || [settingsObjectClass allowRestoreToDefaults]) {
			NSDictionary *defaultValues = [settingsObjectClass defaultValues];
			for (NSString *key in defaultValues) {
				id value = [defaultValues objectForKey:key];
				if (!value || [NSNull null] == value) {
					if (!excludeNilValues) {
						[appDefaults setObject:[NSNull null] forKey:key];
					}
				} else {
					[appDefaults setObject:value forKey:key];
				}
			}			
		}
	}
	
	//Add a boolean to see if this is the first run of the app
	if (!excludeNonRestorable) {
		[appDefaults setObject:[NSNumber numberWithBool:YES] forKey:self.firstRunKey];
	}	
	return appDefaults;
}

@end
