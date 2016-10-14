//
//  BMYouTubeListCompatibleVideosService.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/20/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMYouTubeListDirectStreamableVideosService.h>
#import <BMCommons/BMGetYouTubeStreamInfoService.h>
#import <BMCommons/NSArray+BMCommons.h>
#import <BMYouTube/BMYouTube.h>
#import <GData/GData.h>

@implementation BMYouTubeListDirectStreamableVideosService {
    NSMutableArray *_resultsToProcess;
    NSMutableArray *_validEntries;
    NSUInteger _numberOfEntries;
}

@synthesize wrappedService, numberOfEntries = _numberOfEntries;

- (id)init {
    if ((self = [super init])) {

        _resultsToProcess = [NSMutableArray new];
        _validEntries = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc {
    BM_RELEASE_SAFELY(_resultsToProcess);
    BM_RELEASE_SAFELY(_validEntries);
}

- (BOOL)executeWithError:(NSError **)error {
    [_resultsToProcess removeAllObjects];
    [_validEntries removeAllObjects];    
    [self executeService:self.wrappedService];
    return YES;
}

- (void)service:(id<BMService>)service succeededWithResult:(id)result {
    if (service == self.wrappedService) {
        if ([result isKindOfClass:[NSArray class]]) {
            [_resultsToProcess addObjectsFromArray:result];
            _numberOfEntries = _resultsToProcess.count;
        }
    } else {
        NSDictionary *dict = result;
        NSString *directUrl = dict[BMYouTubeQualityMedium];
        if (directUrl) {
            GDataEntryYouTubeVideo *entry = service.context;
            [_validEntries addObject:entry];
        }
    }
    [self processNextResult];
}

- (void)service:(id<BMService>)service failedWithError:(NSError *)error {
    if (service == self.wrappedService) {
        [self serviceFailedWithRawError:error];
    } else {
        [self processNextResult];
    }
}

- (void)processNextResult {
    GDataEntryYouTubeVideo *entry = [_resultsToProcess firstObject];
    BOOL hasNext = entry != nil;
    if (hasNext) {
        [_resultsToProcess removeObjectAtIndex:0];
        BMGetYouTubeStreamInfoService *service = [[BMGetYouTubeStreamInfoService alloc] init];
        service.videoId = [[entry mediaGroup] videoID];
        service.context = entry;
        [self executeService:service];
    }
    
    if (!hasNext) {
        [self serviceSucceededWithRawResult:_validEntries];
    }
}

@end
