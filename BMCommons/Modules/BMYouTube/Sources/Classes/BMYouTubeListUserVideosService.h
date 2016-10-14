//
//  BMYouTubeListUserVideosService.h
//  BMCommons
//
//  Created by Werner Altewischer on 24/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMMedia/BMMediaContainer.h>
#import <BMYouTube/BMYouTubeService.h>

/**
 Lists the YouTube videos owned by the specified user.
 */
@interface BMYouTubeListUserVideosService : BMYouTubeService

/**
 The feed ID which chooses which videos to retrieve. 
 
 Defaults to kGDataYouTubeUserFeedIDUploads which are the uploads of the user.
 */
@property (nonatomic, strong) NSString *userFeedID;

/**
 The number of entries within the current batch (valid upon succesful completion of the service).
 */
@property (nonatomic, readonly) NSUInteger numberOfEntries;

/**
 The total number of entries (valid upon succesful completion of the service).
 */
@property (nonatomic, readonly) NSUInteger totalNumberOfEntries;

/**
 The start index for retrieving the results.
 
 Default is 0. 
 This index will update itself after succesful completion, so this service may be reused to retrieve the next batch.
 */
@property (nonatomic, assign) NSUInteger startIndex;


/** 
 The batch size for retrieving entries.
 
 Defaults to 20.
 */
@property (nonatomic, assign) NSUInteger maxResults;

@end
