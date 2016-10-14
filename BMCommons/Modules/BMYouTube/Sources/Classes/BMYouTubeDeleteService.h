//
//  BMYouTubeDeleteService.h
//  BMCommons
//
//  Created by Werner Altewischer on 25/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaContainer.h>
#import <BMYouTube/BMYouTubeService.h>

/**
 Service to delete a video from YouTube.
 
 This service has no return value upon success.
 */
@interface BMYouTubeDeleteService : BMYouTubeService

/**
 The url for the YouTube video entry.
 
 @see [BMVideoContainer entryUrl]
 */
@property (nonatomic, strong) NSString *entryUrl;

@end