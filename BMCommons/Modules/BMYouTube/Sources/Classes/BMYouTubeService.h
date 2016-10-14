//
//  BMYouTubeService.h
//  BMCommons
//
//  Created by Werner Altewischer on 08/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMGoogle/BMGoogleService.h>

/**
 Abstract base implementation for YouTube services.
 */
@interface BMYouTubeService : BMGoogleService

/**
 The developer key to use to authenticate with YouTube.
 */
@property (nonatomic, strong) NSString *developerKey;

/**
 The user ID of the YouTube user.
 
 Defaults to kGDataServiceDefaultUser which is the authenticated user.
 */
@property (nonatomic, strong) NSString *userID;

@end
