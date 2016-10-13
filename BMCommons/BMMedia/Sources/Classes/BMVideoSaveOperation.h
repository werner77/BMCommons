//
//  BMVideoSaveOperation.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/31/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaSaveOperation.h>

/**
 Operation to save a video file to BMVideoContainer.
 
 After save the video will have its thumbnailImage, midSizeImage, duration and filePath set.
 */
@interface BMVideoSaveOperation : BMMediaSaveOperation 
/**
 The source path for the video file.
 */
@property (strong, readonly) NSString *originalVideoPath;

/**
 The final path for the video file.
 */
@property (strong, readonly) NSString *finalVideoPath;

/**
 The image to use as presentation for the video file when not started.
 */
@property (readonly) UIImage *image;

/**
 If set to true the video is also saved to the camera roll.
 */
@property (assign) BOOL saveToCameraRoll;

/**
 Initializes with video container to save to, filepath and presentation image.
 */
- (id)initWithVideo:(id <BMVideoContainer>)theVideo originalVideoPath:(NSString *)originalPath image:(UIImage *)theImage;

/**
 The video.
 */
- (id <BMVideoContainer>)video;

@end
