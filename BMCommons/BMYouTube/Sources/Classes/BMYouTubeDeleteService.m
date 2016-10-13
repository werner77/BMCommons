//
//  BMYouTubeDeleteService.m
//  BMCommons
//
//  Created by Werner Altewischer on 25/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMYouTubeDeleteService.h"
#import "BMMediaContainer.h"
#import "BMStringHelper.h"
#import "GDataEntryYouTubeUpload.h"
#import "GDataGeo.h"
#import "GDataMediaGroup.h"
#import "BMYouTubeEntryTransformer.h"
#import "BMYouTubeUploadTransformer.h"
#import "BMErrorHelper.h"
#import "GDataServiceGoogleYouTube.h"
#import <GData/GData.h>
#import <BMYouTube/BMYouTube.h>

@interface BMYouTubeDeleteService(Private)

- (GDataServiceGoogleYouTube *)youTubeService;

@end

@implementation BMYouTubeDeleteService {
    NSString *entryUrl;
}

@synthesize entryUrl;

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}


#pragma mark - Protected methods

- (void)configureService:(GDataServiceGoogle *)theService {
    [super configureService:theService];
}

- (GDataServiceTicket *)initiateService:(GDataServiceGoogle *)theService withError:(NSError **)error {
    GDataServiceGoogleYouTube *youTubeService = (GDataServiceGoogleYouTube *)theService;
    NSString *urlString = self.entryUrl;
    NSURL *url = [BMStringHelper urlFromString:urlString];
    if (url) {
        return [youTubeService fetchEntryWithURL:url entryClass:[GDataEntryYouTubeVideo class] delegate:self didFinishSelector:@selector(fetchTicket:finishedWithEntry:error:)];    
    } else {
        if (error) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_INVALID_DATA description:BMYouTubeLocalizedString(@"service.delete.error.invalidentry", @"Video entry URL is not valid")];
        }
        return nil;
    }
}


#pragma mark - Fetch callback

- (void)fetchTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)entry
               error:(NSError *)error {
	if (error == nil) {
        [self setCurrentTicket:[self.youTubeService deleteEntry:entry delegate:self didFinishSelector:@selector(deleteTicket:finishedWithEntry:error:)]];
	} else {
        [self serviceFailedWithRawError:error];
	}
}

- (void)deleteTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error {
	if (error == nil) {
        [self serviceSucceededWithRawResult:nil];
	} else {
        [self serviceFailedWithRawError:error];
	}
}

@end

@implementation BMYouTubeDeleteService(Private)

- (GDataServiceGoogleYouTube *)youTubeService {
    return (GDataServiceGoogleYouTube *)self.googleService;
}

@end