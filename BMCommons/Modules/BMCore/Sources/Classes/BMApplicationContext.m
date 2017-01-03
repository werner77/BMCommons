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

@implementation BMApplicationContext 

@synthesize settings;
@synthesize active;
@synthesize serviceManager;
@synthesize operationQueue;

BM_SYNTHESIZE_DEFAULT_SINGLETON

- (id)init {
	if ((self = [super init])) {
        
        NSArray *settingsClasses = [self settingsObjectClasses];
        if (settingsClasses) {
            settings = [[BMSettingsRegistry alloc] initWithClasses:settingsClasses];
        }
        
        delegates = BMCreateNonRetainingArray();

        serviceManager = [BMServiceManager sharedInstance];

		environment = [NSMutableDictionary new];
        operationQueue = [BMOperationQueue sharedInstance];

		[self loadSettings];
	}
	return self;
}

- (void)dealloc {
	if (self.active) {
		[self terminate];
	}
	BM_RELEASE_SAFELY(environment);
	BM_RELEASE_SAFELY(serviceManager);
	BM_RELEASE_SAFELY(delegates);
	[self stopListeningForNotifications];
	BM_RELEASE_SAFELY(settings);
    
    BM_RELEASE_SAFELY(operationQueue);
}

#pragma mark -
#pragma mark Abstract methods

- (NSArray *)settingsObjectClasses {
	return nil;
}

#pragma mark -
#pragma mark Environment

- (void)setObject:(id)object forEnvironmentVariable:(NSString *)variable {
	if (object) {
		[environment setObject:object forKey:variable];
	} else {
		[environment removeObjectForKey:variable];
	}
}

- (id)objectForEnvironmentVariable:(NSString *)variable {
	return [environment objectForKey:variable];
}

- (NSDictionary *)environment {
	return [NSDictionary dictionaryWithDictionary:environment];
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
	return [NSArray arrayWithArray:delegates];
}

- (void)addDelegate:(id <BMApplicationContextDelegate>)delegate {
	if (![delegates bmContainsObjectIdenticalTo:delegate]) {
		[delegates addObject:delegate];
	}
}

- (void)addPriorityDelegate:(id <BMApplicationContextDelegate>)delegate {
	if (![delegates bmContainsObjectIdenticalTo:delegate]) {
		[delegates insertObject:delegate atIndex:0];
	}
}

- (void)removeDelegate:(id <BMApplicationContextDelegate>)delegate {
	[delegates removeObjectIdenticalTo:delegate];
}

- (void)initialize {
    
    if (!settings.isLoaded) {
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
	
	[environment addEntriesFromDictionary:[[NSProcessInfo processInfo] environment]];
	
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
	[settings save];
}

- (void)loadSettings {
    [settings load];
}

- (void)activate {
	//Call this here as well because otherwise the [settings load] call may call reset on the settings objects in case of first run
	[settings finishedInitialization];
	    
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
	[settings finishedInitialization];
	for (id <BMApplicationContextDelegate> delegate in self.delegates) {
		if ([(NSObject *)delegate respondsToSelector:@selector(applicationContextDidInitialize:)]) {
			[delegate applicationContextDidInitialize:self];
		}
	}	
}

@end

@implementation BMApplicationContext(Private)

@end
