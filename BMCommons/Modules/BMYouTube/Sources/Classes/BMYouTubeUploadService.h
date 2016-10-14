//
//  BMYouTubeUploadService.h
//  BMCommons
//
//  Created by Werner Altewischer on 08/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMYouTube/BMYouTubeService.h>
#import <BMMedia/BMMediaContainer.h>

/**
 Service for uploading a video to YouTube.
 */
@interface BMYouTubeUploadService : BMYouTubeService 

/**
 The video to upload.
 */
@property (nonatomic, strong) id <BMVideoContainer> video;

/**
 Value transformer to transform the Youtube video entry returned by YouTube to a video container after the upload is successful.
 
 If unset a BMYouTubeVideoEntryTransformer is used with the video object (see the video property) set as argument so it populates that video instead of creating a new one. It will populate the entryId and entryUrl with the YouTube video ID and URL to modify the entry.
 */
@property (nonatomic, strong) NSValueTransformer *videoEntryTransformer;

/**
 Value transformer to use to convert the video to a GDataEntryYouTubeUpload instance. 
 
 If unset an instance of BMYouTubeUploadTransformer is used.
 */
@property (nonatomic, strong) NSValueTransformer *videoUploadTransformer;

@end
