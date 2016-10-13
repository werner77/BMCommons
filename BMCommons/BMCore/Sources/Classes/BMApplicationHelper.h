//
//  BMApplicationHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMCoreObject.h>

/**
 Application utility methods.
 */
@interface BMApplicationHelper : BMCoreObject {

}

/**
 Run the runloop for a short time interval to allow views to be updated or other events to be processed.
 */
+ (void)doEvents;

/**
 Plays a sound from the specified sound file.
 
 @param soundFileName Name of the sound file within the bundle
 @param bundle The bundle to load the file from or nil for the main bundle.
 @param alert Whether or not to play the sound in alert mode.
 */
+ (void)playSoundFromFile:(NSString *)soundFileName fromBundle:(NSBundle *)bundle asAlert:(BOOL)alert;

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
