//
//  BMApplicationHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Application utility methods.
 */
@interface BMApplicationHelper : BMCoreObject {

}

/**
 Run the current runloop for a short time interval to allow views to be updated or other events to be processed.

 Default interval is 0.1 seconds.
 */
+ (void)doEvents;

/**
 Run the current runloop until the specified date.
 */
+ (void)doEventsUntilDate:(NSDate *)date;

/**
 Plays a sound from the specified sound file.
 
 @param soundFileName Name of the sound file within the bundle
 @param bundle The bundle to load the file from or nil for the main bundle.
 @param alert Whether or not to play the sound in alert mode.
 */
+ (void)playSoundFromFile:(NSString *)soundFileName fromBundle:(nullable NSBundle *)bundle asAlert:(BOOL)alert;

/**
 Plays a sound from the file with the specified URL.
 
 @param soundFileURL The URL for the sound file to play.
 @param alert Whether or not to play the sound in alert mode.
 */
+ (void)playSoundFromURL:(NSURL *)soundFileURL asAlert:(BOOL)alert;

/**
 Removes all registered sounds from the cache to free up memory.
 */
+ (void)clearSoundCache;

@end

NS_ASSUME_NONNULL_END
