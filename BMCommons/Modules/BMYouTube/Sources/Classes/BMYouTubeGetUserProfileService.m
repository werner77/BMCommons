//
//  BMYouTubeGetUserProfileService.m
//  BMCommons
//
//  Created by Werner Altewischer on 10/06/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMYouTubeGetUserProfileService.h>
#import "GDataEntryYouTubeVideo.h"
#import <BMCommons/BMErrorHelper.h>
#import <GData/GData.h>

@interface BMYouTubeGetUserProfileService(Private)

@end

@implementation BMYouTubeGetUserProfileService {
    NSString *userFeedID;
}

@synthesize userFeedID;

- (id)init {
    if ((self = [super init])) {
        self.userFeedID = kGDataYouTubeUserFeedIDProfile;
    }
    return self;
}


#pragma mark - Protected methods

- (GDataServiceTicket *)initiateService:(GDataServiceGoogle *)theService withError:(NSError **)error {
    NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForUserID:self.userID
                                                         userFeedID:self.userFeedID];
    return [theService fetchFeedWithURL:feedURL
                               delegate:self
                      didFinishSelector:@selector(entryListFetchTicket:finishedWithEntry:error:)];
}

#pragma mark - Overridden methods

#pragma mark - Feed callback

// feed fetch callback
- (void)entryListFetchTicket:(GDataServiceTicket *)ticket
            finishedWithEntry:(GDataEntryYouTubeUserProfile *)entry
                       error:(NSError *)error {
    
    if (error) {
        [self serviceFailedWithRawError:error];
    } else {
        [self serviceSucceededWithRawResult:entry];
    }
    [self setCurrentTicket:nil];
}

@end
