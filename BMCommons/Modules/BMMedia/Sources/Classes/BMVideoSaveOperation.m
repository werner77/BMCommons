//
//  VideoSaveOperation.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/31/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <BMCommons/BMVideoSaveOperation.h>
#import <AVFoundation/AVFoundation.h>
#import <BMCommons/BMCore.h>

@interface BMVideoSaveOperation (Private)

- (void)saveVideoFromPath:(NSString *)thePath withImage:(UIImage *)theImage;
- (void)determineFinalVideoPath;

@end

@implementation BMVideoSaveOperation {
	NSString *originalVideoPath;
	NSString *finalVideoPath;
	BOOL saveToCameraRoll;
	UIImage *image;
}

@synthesize originalVideoPath, finalVideoPath, saveToCameraRoll, image;

- (id)initWithVideo:(id <BMVideoContainer>)theVideo originalVideoPath:(NSString *)originalPath image:(UIImage *)theImage {
	if ((self = [super initWithMedia:theVideo])) {
		originalVideoPath = originalPath;
		image = theImage;
		finalVideoPath = nil;
	}
	return self;
}


- (id <BMVideoContainer>)video {
	return (id <BMVideoContainer>)self.media;
}

- (void)performOperation {
	[self saveVideoFromPath:self.originalVideoPath withImage:self.image];
	
	if (self.saveToCameraRoll && ![self isCancelled]) {
		if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.finalVideoPath)) {			
			UISaveVideoAtPathToSavedPhotosAlbum (self.finalVideoPath, nil, nil, nil);
		} else {
			LogWarn(@"Video not compatible with saved photos album: video not saved");
		}
	}
}

@end

@implementation BMVideoSaveOperation (Private)

- (NSNumber *)determineDuration:(NSString *)thePath {
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:thePath]];
    if (!asset) {
        return nil;
    }
    CMTime timeDuration = asset.duration;
    double seconds = CMTimeGetSeconds(timeDuration);
    return @(seconds);
}

- (void)saveVideoFromPath:(NSString *)thePath withImage:(UIImage *)theImage {
    if (![self isCancelled]) {
        [(NSObject *)self.video performSelectorOnMainThread:@selector(setMidSizeImage:) withObject:theImage waitUntilDone:YES];
    }
    if (![self isCancelled]) {
        [(NSObject *)self.video performSelectorOnMainThread:@selector(setDuration:) withObject:[self determineDuration:thePath] waitUntilDone:YES];
    }
    if (![self isCancelled]) {
		[self.video saveThumbnailImage:theImage];
	}
	if (![self isCancelled]) {
		[(NSObject *)self.video performSelectorOnMainThread:@selector(setDataFromFile:) withObject:thePath waitUntilDone:YES];
	}
	if (![self isCancelled]) {
		[self performSelectorOnMainThread:@selector(determineFinalVideoPath) withObject:nil waitUntilDone:YES];
	}
}

- (void)determineFinalVideoPath {
    @synchronized(self) {
        NSString *theFilePath = [self.video filePath];
        if (finalVideoPath != theFilePath) {
            finalVideoPath = theFilePath;
        }
    }
}

@end

