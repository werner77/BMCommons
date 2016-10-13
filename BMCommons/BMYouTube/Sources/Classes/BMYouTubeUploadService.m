//
//  BMYouTubeUploadService.m
//  BMCommons
//
//  Created by Werner Altewischer on 08/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMYouTubeUploadService.h>
#import <BMCommons/BMMediaContainer.h>
#import <BMCommons/BMStringHelper.h>
#import "GDataEntryYouTubeUpload.h"
#import "GDataGeo.h"
#import "GDataMediaGroup.h"
#import <BMCommons/BMYouTubeEntryTransformer.h>
#import <BMCommons/BMYouTubeUploadTransformer.h>
#import <BMCommons/BMErrorHelper.h>
#import <GData/GData.h>
#import <BMYouTube/BMYouTube.h>

@interface BMYouTubeUploadService(Private)

- (GDataEntryYouTubeUpload *)entryForVideo:(id <BMVideoContainer>)videoContainer;

@end

@implementation BMYouTubeUploadService {
    id <BMVideoContainer> video;
    NSValueTransformer *videoEntryTransformer;
    NSValueTransformer *videoUploadTransformer;
}

@synthesize video, videoEntryTransformer, videoUploadTransformer;

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}


#pragma mark - Protected methods

- (void)configureService:(GDataServiceGoogle *)theService {
    [super configureService:theService];
    [theService setServiceUploadProgressSelector:@selector(ticket:hasDeliveredByteCount:ofTotalByteCount:)];	
}

- (GDataServiceTicket *)initiateService:(GDataServiceGoogle *)theService withError:(NSError **)error {
    GDataServiceGoogleYouTube *youTubeService = (GDataServiceGoogleYouTube *)theService;
    
    NSURL *feedURL = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:self.userID];
    
    GDataEntryYouTubeUpload *entry = [self entryForVideo:self.video];
    
    if (!entry) {
        if (error) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_INVALID_DATA description:BMYouTubeLocalizedString(@"service.upload.error.novideo", @"Video to upload could not be located")];
        }
        return nil;
    }
    
    return [youTubeService fetchEntryByInsertingEntry:entry
                                           forFeedURL:feedURL
                                             delegate:self
                                    didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];
}

    
#pragma mark - Progress callback

- (void)ticket:(GDataServiceTicket *)ticket hasDeliveredByteCount:(unsigned long long)numberOfBytesRead ofTotalByteCount:(unsigned long long)dataLength {
    double progress = ((double)numberOfBytesRead) / ((double) dataLength);
    [self updateProgress:progress withMessage:nil];
}

#pragma mark - Upload callback

- (void)uploadTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error {
	
	if (error == nil) {
        NSValueTransformer *vt = self.videoEntryTransformer;
        
        NSNumber *duration = self.video.duration;
        
        if (!vt) {
            vt = [[BMYouTubeEntryTransformer alloc] initWithVideoContainer:self.video];
        }
        
        id<BMVideoContainer> result = [vt transformedValue:videoEntry];
        
        if (result.duration == nil || [result.duration intValue] == 0) {
            //Copy duration from original video
            result.duration = duration;
        }
        
		[self serviceSucceededWithRawResult:result];
	} else {
        [self serviceFailedWithRawError:error];
	}
}


@end

@implementation BMYouTubeUploadService(Private)


- (GDataEntryYouTubeUpload *)entryForVideo:(id <BMVideoContainer>)videoContainer {
    NSValueTransformer *vt = self.videoUploadTransformer;
    if (!vt) {
        vt = [BMYouTubeUploadTransformer new];
    }
    return [vt transformedValue:self.video];
}


@end
