//
//  BMYouTubeGetUserProfileService.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/06/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMYouTube/BMYouTubeService.h>

/**
 Service to retrieve the YouTube user profile.
 
 This service returns a GDataEntryYouTubeUserProfile object if successful.
 */
@interface BMYouTubeGetUserProfileService : BMYouTubeService

/**
 The feed ID for the user. 
 
 Is used together with the userID to generate a URL for retrieving the feed using the method
 [GDataServiceGoogleYouTube youTubeURLForUserID:userFeedID:]
 
 It defaults to kGDataYouTubeUserFeedIDProfile.
 */
@property (nonatomic, strong) NSString *userFeedID;

@end


