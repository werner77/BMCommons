//
//  BMYouTubeListUserVideosService.m
//  BMCommons
//
//  Created by Werner Altewischer on 24/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMYouTubeListUserVideosService.h>
#import <GData/GDataEntryYouTubeVideo.h>
#import <BMCore/BMErrorHelper.h>
#import <GData/GDataQuery.h>
#import <GData/GData.h>

@interface BMYouTubeListUserVideosService(Private)

@end

@implementation BMYouTubeListUserVideosService {
    GDataLink *_nextLink;
    NSUInteger _startIndex;
    NSUInteger _numberOfEntries;
    NSUInteger _totalNumberOfEntries;
    NSUInteger _maxResults;
}

@synthesize userFeedID, startIndex = _startIndex, numberOfEntries = _numberOfEntries, totalNumberOfEntries = _totalNumberOfEntries, maxResults = _maxResults;

- (id)init {
    if ((self = [super init])) {
        self.userFeedID = kGDataYouTubeUserFeedIDUploads;
        self.maxResults = 20;
    }
    return self;
}

- (void)dealloc {
    [self setCurrentTicket:nil];
}

#pragma mark - Protected methods

- (void)configureService:(GDataServiceGoogle *)theService {
    [super configureService:theService];
    [theService setServiceShouldFollowNextLinks:NO];
}

- (GDataServiceTicket *)initiateService:(GDataServiceGoogle *)theService withError:(NSError **)error {
    NSURL *feedURL = nil;
    if (self.currentTicket) {
        feedURL = [_nextLink URL];
        if (feedURL) {
            return [theService fetchFeedWithURL:feedURL
                                       delegate:self
                              didFinishSelector:@selector(entryListFetchTicket:finishedWithFeed:error:)];
        } else {
            [self performSelector:@selector(serviceSucceededWithResult:) withObject:@[] afterDelay:0.0];
            return self.currentTicket;
        }
        
    } else {
        feedURL = [GDataServiceGoogleYouTube youTubeURLForUserID:self.userID
                                                      userFeedID:self.userFeedID];
        
        GDataQuery *query = [GDataQuery queryWithFeedURL:feedURL];
        
        //Start index is 1-based
        [query setStartIndex:self.startIndex + 1];
        [query setMaxResults:self.maxResults];
        
        return [theService fetchFeedWithQuery:query
                              delegate:self
                     didFinishSelector:@selector(entryListFetchTicket:finishedWithFeed:error:)];
        
    }
}

#pragma mark - Overridden methods

#pragma mark - Feed callback

// feed fetch callback
- (void)entryListFetchTicket:(GDataServiceTicket *)ticket
            finishedWithFeed:(GDataFeedYouTubeVideo *)feed
                       error:(NSError *)error {
    
    if (error) {
        [self serviceFailedWithRawError:error];
    } else {
        NSArray *entries = [feed entries];
        _startIndex = [feed.startIndex unsignedIntegerValue];
        //start index is 1-based
        if (_startIndex > 0) {
            _startIndex--;
        }
        _numberOfEntries = entries.count;
        _totalNumberOfEntries = [feed.totalResults integerValue];
        
        if (_nextLink != feed.nextLink) {
            _nextLink = feed.nextLink;
        }
        [self serviceSucceededWithRawResult:entries];
    }
}

@end

@implementation BMYouTubeListUserVideosService(Private)

@end

