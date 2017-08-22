//
//  BMApplicationContext.m
//  BehindMedia
//
//  Created by Werner Altewischer on 28/08/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <BMCommons/BMApplicationContext.h>
#import <BMCommons/BMURLCache.h>
#import <BMCommons/BMFileHelper.h>
#import <BMCommons/BMApplicationHelper.h>
#import <BMCommons/BMCore.h>
#import <BMCommons/BMApp.h>
#import <BMCommons/NSArray+BMCommons.h>

#define STORE_DESCRIPTOR_FILENAME @"storedescriptor.scd"

@interface BMApplicationContext(Private)


@end

@implementation BMApplicationContext  {
	NSMutableArray *_delegates;
	NSMutableDictionary *_environment;
}

BM_SYNTHESIZE_DEFAULT_SINGLETON

- (id)init {
	if ((self = [super init])) {
        
        NSArray *settingsClasses = [self settingsObjectClasses];
        _settings = [[BMSettingsRegistry alloc] initWithClasses:settingsClasses];
        _delegates = BMCreateNonRetainingArray();

        _serviceManager = [BMServiceManager sharedInstance];

		_environment = [NSMutableDictionary new];
        _operationQueue = [BMOperationQueue sharedInstance];

		[self loadSettings];
	}
	return self;
}

- (void)dealloc {
	if (self.active) {
		[self terminate];
	}
	BM_RELEASE_SAFELY(_environment);
	BM_RELEASE_SAFELY(_serviceManager);
	BM_RELEASE_SAFELY(_delegates);
	[self stopListeningForNotifications];
	BM_RELEASE_SAFELY(_settings);
    BM_RELEASE_SAFELY(_operationQueue);
}

#pragma mark -
#pragma mark Abstract methods

- (NSArray *)settingsObjectClasses {
	return @[];
}

#pragma mark -
#pragma mark Environment

- (void)setObject:(id)object forEnvironmentVariable:(NSString *)variable {
	if (object) {
		[_environment setObject:object forKey:variable];
	} else {
		[_environment removeObjectForKey:variable];
	}
}

- (id)objectForEnvironmentVariable:(NSString *)variable {
	return [_environment objectForKey:variable];
}

- (NSDictionary *)environment {
	return [NSDictionary dictionaryWithDictionary:_environment];
}

#pragma mark -
#pragma mark Other methods

- (NSString *)appVersion {
	return [[BMApp sharedInstance] version];
}

- (NSString *)fullAppVersion {
	return [[BMApp sharedInstance] fullVersion];
}

- (NSString *)appBuild {
	return [[BMApp sharedInstance] build];
}

- (NSArray *)delegates {
	return [NSArray arrayWithArray:_delegates];
}

- (void)addDelegate:(id <BMApplicationContextDelegate>)delegate {
	if (![_delegates bmContainsObjectIdenticalTo:delegate]) {
		[_delegates addObject:delegate];
	}
}

- (void)addPriorityDelegate:(id <BMApplicationContextDelegate>)delegate {
	if (![_delegates bmContainsObjectIdenticalTo:delegate]) {
		[_delegates insertObject:delegate atIndex:0];
	}
}

- (void)removeDelegate:(id <BMApplicationContextDelegate>)delegate {
	[_delegates removeObjectIdenticalTo:delegate];
}

- (void)initialize {
    
    if (!self.settings.isLoaded) {
        [self loadSettings];
    }
    
	//Initialize the TT caching/queue
	BMURLCache *ttCache = [BMURLCache sharedCache];
	
	//Allow the equivalent of 2 fullsize images to be cached in memory
	ttCache.maxPixelCount = 2 * 1600 * 1200;
	//ttCache.disableImageCache = NO;
	
	//Never expire
	ttCache.invalidationAge = 3600.0 * 24.0 * 365.0 * 100.0;
    
    //500 MB of cache
    ttCache.maxDiskSpace = 500 * 1000 * 1000L;
	
	NSURLCache *urlCache = [NSURLCache sharedURLCache];
	urlCache.diskCapacity = 10 * 1024 * 1024;
	urlCache.memoryCapacity = 100 * 1024;
	
	[_environment addEntriesFromDictionary:[[NSProcessInfo processInfo] environment]];
	
	[self startListeningForNotifications];
	
	self.active = YES;
	
	[self performSelector:@selector(delayedInitialization) withObject:nil afterDelay:0.0];
}

- (void)clearCaches {
	//Clear the TTURLMemory cache. 
	BMURLCache *cache = [BMURLCache sharedCache];
	[cache removeAll:NO];
    [BMApplicationHelper clearSoundCache];
}

- (void)save {
	LogInfo(@"Saving application context");
    
	[self saveSettings];
}

- (void)terminate {
	self.active = NO;
	[self save];
	[self stopListeningForNotifications];
    [self.operationQueue terminate];
}

- (void)saveSettings {
	[self.settings save];
}

- (void)loadSettings {
    [self.settings load];
}

- (void)activate {
	//Call this here as well because otherwise the [settings load] call may call reset on the settings objects in case of first run
	[self.settings finishedInitialization];
	    
	//Make sure that the settings are restored, since the user may have changed them via 'User Settings' of the iPhone/iPad device
	[self loadSettings];
}

- (void)deactivate {
	[self save];
}


#pragma mark -
#pragma mark Protected methods

- (void)startListeningForNotifications {
#if TARGET_OS_IPHONE
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCaches) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
}

- (void)stopListeningForNotifications {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)delayedInitialization {
	[self.settings finishedInitialization];
	for (id <BMApplicationContextDelegate> delegate in self.delegates) {
		if ([(NSObject *)delegate respondsToSelector:@selector(applicationContextDidInitialize:)]) {
			[delegate applicationContextDidInitialize:self];
		}
	}	
}

@end

@implementation BMApplicationContext(Private)

@end
