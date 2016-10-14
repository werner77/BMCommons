//
//  BMYouTubeService.m
//  BMCommons
//
//  Created by Werner Altewischer on 08/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMYouTubeService.h>
#import <BMYouTube/BMYouTube.h>
#import <GoogleAPIClientForREST/GTLRYouTube.h>

@implementation BMYouTubeService {
    NSString *developerKey;
    NSString *userID;
}

@synthesize developerKey, userID;

- (id)init {
    if ((self = [super init])) {

        self.userID = kGDataServiceDefaultUser;
    }
    return self;
}


- (void)configureService:(GTLRService *)theService {
    [super configureService:theService];
    GTLRYouTubeService *youTubeService = (GTLRYouTubeService *)theService;
    [youTubeService setYouTubeDeveloperKey:self.developerKey];
}

- (Class)googleServiceClass {
    return [GTLRYouTubeService class];
}

@end
