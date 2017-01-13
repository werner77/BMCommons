//
// Created by Werner Altewischer on 02/09/16.
// Copyright (c) 2016 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Class for performing data recording and playback.
 */
@interface BMDataRecorder : NSObject

/**
 * Path to directory to store to/read from for recorded responses.
 *
 * Defaults to the current working directory.
 */
@property (nonatomic, strong) NSString *recordingDirPath;

/**
 * Path for the current recording identifier.
 */
@property (nonatomic, readonly) NSString *currentRecordingIdentifier;

/**
 * Whether playback is currently active or not
 */
@property (nonatomic, readonly, getter=isPlayingBack) BOOL playingBack;

/**
 * Whether recording is currently active or not
 */
@property (nonatomic, readonly, getter=isRecording) BOOL recording;

/**
 * Starts a recording with the specified unique recording identifier to identify the recording.
 *
 * Will fail if a playback is active currently.
 */
- (void)startRecordingWithIdentifier:(NSString *)recordingIdentifier;

/**
 * Finishes the current recording.
 *
 * If success == true the recording is committed, otherwise all intermediate recorded files will be deleted.
 */
- (void)finishRecordingWithSuccess:(BOOL)success;

/**
 * Starts playback with the specified unique recording identitier. A recording should be done previously otherwise each response will result in a generic connection failure error.
 * Same is true for request for which no data was recorded.
 *
 * Will fail if a recording is active currently.
 */
- (void)startPlaybackWithIdentifier:(NSString *)recordingIdentifier;

/**
 * Finishes playback.
 */
- (void)finishPlayback;

/**
 * Works only in recording mode: saves the specified result for the specified recording class and digest.
 */
- (void)recordResult:(id)result forRecordingClass:(NSString *)recordingClassIdenfier withDigest:(NSString *)digest;

/**
 * Works only in playback mode: loads the recorded result for the specified recording class and digest.
 */
- (id)recordedResultForRecordingClass:(NSString *)recordingClassIdentier withDigest:(NSString *)digest;

/**
 * Writes a message to the recording log.
 *
 * @param message
 */
- (void)writeToRecordingLog:(NSString *)message;

@end