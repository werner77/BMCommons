//
// Created by Werner Altewischer on 02/09/16.
// Copyright (c) 2016 BehindMedia. All rights reserved.
//

#import <BMCommons/BMDataRecorder.h>
#import <BMCommons/BMLogging.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMObjectHelper.h>
#import <BMCommons/NSObject+BMCommons.h>

@implementation BMDataRecorder {
    NSMutableDictionary *_recordingDictionary;
    NSFileHandle *_recordingLogFileHandle;
}

- (instancetype)init {
    if (self = [super init]) {
        _recordingDictionary = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - Recording/Playback

- (NSString *)recordingDirPath {
    NSString *ret = _recordingDirPath;
    if (_recordingDirPath == nil) {
        ret = [NSFileManager defaultManager].currentDirectoryPath;
    }
    return ret;
}

- (NSUInteger)incrementedRecordingCountForServiceOfClass:(NSString *)serviceClassName withDigest:(NSString *)digest {
    NSString *key = [NSString stringWithFormat:@"%@-%@", serviceClassName, [BMStringHelper filterNilString:digest]];
    NSNumber *n = [_recordingDictionary objectForKey:key];
    if (n == nil) {
        n = @(1);
    } else {
        n = @(n.unsignedIntegerValue + 1);
    }
    [_recordingDictionary setObject:n forKey:key];
    return [n unsignedIntegerValue];
}

- (NSString *)currentRecordingDir {
    if (self.recordingDirPath == nil) {
        LogWarn(@"No recording directory is set");
        return nil;
    } else if (self.currentRecordingIdentifier == nil) {
        LogWarn(@"Current recording identifier is not set");
        return nil;
    }
    return [NSString stringWithFormat:@"%@/%@", self.recordingDirPath, self.currentRecordingIdentifier];
}

- (NSString *)nextResultPathForRecordingClass:(NSString *)recordingClass withDigest:(NSString *)digest forWriting:(BOOL)forWriting {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *serviceClassName = recordingClass;
    NSUInteger count = [self incrementedRecordingCountForServiceOfClass:serviceClassName withDigest:digest];
    BOOL first = _recordingDictionary.count == 0;

    NSError *error = nil;
    NSString *directory = [self currentRecordingDir];
    BOOL isDirectory = NO;

    if (directory == nil) {
        return nil;
    }

    BOOL exists = [fm fileExistsAtPath:directory isDirectory:&isDirectory];

    if (exists && first && forWriting) {
        //Remove existing directory
        if (![fm removeItemAtPath:directory error:&error]) {
            LogWarn(@"Could not remove existing directory: %@: %@", directory, error);
            return nil;
        } else {
            exists = NO;
        }
    }

    if (exists) {
        if (isDirectory) {
            //OK: directory exists already.
        } else {
            //Conflict: file exists but is not a directory
            LogWarn(@"File exists in place of directory: %@", directory);
            return nil;
        }
    } else {
        if (!forWriting) {
            LogWarn(@"Directory does not exist at path: %@", directory);
            return nil;
        } else if ([fm createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error]) {
            //OK directory successfully created
        } else {
            //Failed to create directory
            LogWarn(@"Could not create directory: %@", directory);
            return nil;
        }
    }

    NSMutableString *resultFile = [NSMutableString new];
    for (id p in @[[BMObjectHelper filterNullObject:serviceClassName], [BMObjectHelper filterNullObject:digest], [BMObjectHelper filterNullObject:@(count)]]) {
        id part = [BMObjectHelper filterNSNullObject:p];
        if (part != nil) {
            if (resultFile.length > 0) {
                [resultFile appendString:@"-"];
            }
            [resultFile appendString:[part description]];
        }
    }
    [resultFile appendString:@".dat"];

    NSString *resultPath = [directory stringByAppendingPathComponent:resultFile];

    if (!forWriting) {
        //File should exist
        if ([fm fileExistsAtPath:resultPath isDirectory:&isDirectory] && !isDirectory) {
            //OK
        } else {
            LogWarn(@"File does not exist at path: %@", resultPath);
            return nil;
        }
    }

    return resultPath;
}

- (void)recordResult:(id)result forRecordingClass:(NSString *)recordingClassIdenfier withDigest:(NSString *)digest {
    if (self.isRecording && [result conformsToProtocol:@protocol(NSCoding)]) {
        NSString *resultPath = [self nextResultPathForRecordingClass:recordingClassIdenfier withDigest:digest forWriting:YES];
        if (resultPath == nil) {
            LogWarn(@"Could not create file for response recording '%@' with digest '%@'", recordingClassIdenfier, digest);
        } else {
            BOOL success = NO;
            @try {
                success = [NSKeyedArchiver archiveRootObject:result toFile:resultPath];
            } @catch(NSException *ex) {
                LogWarn(@"Could not archive object: ", ex);
            }

            if (!success) {
                LogWarn(@"Failed recording response for recording '%@' with digest '%@' at path: %@", recordingClassIdenfier, digest, resultPath);
            } else {
                LogNotice(@"Recorded response for recording '%@' with digest '%@' at path: %@", recordingClassIdenfier, digest, resultPath);
            }
        }
    }
}

- (void)writeToRecordingLog:(NSString *)message {
    if (_recordingLogFileHandle == nil && self.isRecording) {
        //First remove any exising log file
        NSString *dir = [self currentRecordingDir];
        NSString *filePath = [dir stringByAppendingPathComponent:@"recording.log"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error]) {
            LogWarn(@"Could not create recording dictory: %@", error);
        }
        if (![fileManager createFileAtPath:filePath contents:[NSData data] attributes:nil]) {
            LogWarn(@"Could not create log file in recording directory: %s", strerror(errno));
        }
        _recordingLogFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        if (_recordingLogFileHandle == nil) {
            LogWarn(@"Recording log file handle could not be created");
        }
    }
    NSString *logMessage = [NSString stringWithFormat:@"----------------------------------------------\n%@----------------------------------------------\n", message];
    [_recordingLogFileHandle writeData:[logMessage dataUsingEncoding:NSUTF8StringEncoding]];
}

- (id)recordedResultForRecordingClass:(NSString *)recordingClassIdentier withDigest:(NSString *)digest {
    id mockResult = nil;
    if (self.isPlayingBack) {
        NSString *resultPath = [self nextResultPathForRecordingClass:recordingClassIdentier withDigest:digest forWriting:NO];
        LogWarn(@"Trying to load recorded result for recording '%@' with digest '%@' at path: %@", recordingClassIdentier, digest, resultPath);

        @try {
            mockResult = (resultPath == nil ? nil : [NSKeyedUnarchiver unarchiveObjectWithFile:resultPath]);
        }
        @catch (NSException *exception) {
            LogWarn(@"Could not deserialize cached response: %@", exception);
        }
        if (mockResult == nil) {
            LogWarn(@"Recorded result could not be loaded");
        } else {
            LogWarn(@"Recorded result was loaded successfully");
        }
    }
    return mockResult;
}

- (void)startRecordingWithIdentifier:(NSString *)recordingIdentifier {
    if (!_recording && !_playingBack && recordingIdentifier.length > 0) {
        _currentRecordingIdentifier = [recordingIdentifier copy];
        _recording = YES;
        [_recordingDictionary removeAllObjects];

        NSString *directory = [self currentRecordingDir];
        NSError *error = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:directory] && ![[NSFileManager defaultManager] removeItemAtPath:directory error:&error]) {
            LogWarn(@"Could not remove existing recording directory before recording: %@: %@", directory, error);
        }
    }
}

- (void)finishRecordingWithSuccess:(BOOL)success {
    if (_recording) {
        if (!success) {
            //rollback recording
            NSString *directory = [self currentRecordingDir];
            NSError *error = nil;
            if (directory != nil && ![[NSFileManager defaultManager] removeItemAtPath:directory error:&error]) {
                LogWarn(@"Could not remove recording directory after failed recording: %@: %@", directory, error);
            }
        }
        _recording = NO;
        _currentRecordingIdentifier = nil;
        [_recordingLogFileHandle closeFile];
        _recordingLogFileHandle = nil;
        [_recordingDictionary removeAllObjects];
    }
}

- (void)startPlaybackWithIdentifier:(NSString *)recordingIdentifier {
    if (!_recording && !_playingBack && recordingIdentifier.length > 0) {
        _playingBack = YES;
        _currentRecordingIdentifier = [recordingIdentifier copy];
        [_recordingDictionary removeAllObjects];
    }
}

- (void)finishPlayback {
    if (_playingBack) {
        _playingBack = NO;
        _currentRecordingIdentifier = nil;
        [_recordingDictionary removeAllObjects];
    }
}

@end