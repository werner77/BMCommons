//
//  BMYouTubeGetVideoInfoService.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/20/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMGetYouTubeStreamInfoService.h>
#import <BMCommons/BMHTTPRequest.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/NSString+BMCommons.h>
#import <BMCommons/BMURLCache.h>
#import <BMMedia/BMMedia.h>

#define kYoutubeInfoURL      @"http://www.youtube.com/get_video_info"
#define kUserAgent @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"

@implementation BMGetYouTubeStreamInfoService

@synthesize videoId;

NSString *const BMYouTubeQualityHigh = @"hd720";
NSString *const BMYouTubeQualityMedium = @"medium";
NSString *const BMYouTubeQualityLow = @"low";


- (id)init {
    if ((self = [super init])) {

        self.readCacheEnabled = YES;
        self.writeCacheEnabled = YES;
        self.loadCachedResultOnError = YES;
    }
    return self;
}

- (void)dealloc {
    BM_RELEASE_SAFELY(videoId);
}

- (BMURLCache *)urlCache {
    BMURLCache *cache = [BMURLCache cacheWithName:@"BMGetYouTubeStreamInfoService"];
    
    //One hour of cache time
    cache.invalidationAge = 3600.0;
    return cache;
}

- (BMHTTPRequest *)requestForServiceWithError:(NSError **)error {
    NSURL *url = [NSURL URLWithString:kYoutubeInfoURL];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"video_id"] = self.videoId;
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
    headers[@"User-Agent"] = kUserAgent;
    
    BMHTTPRequest *r = [[BMHTTPRequest alloc] initGetRequestWithUrl:url
                                                         parameters:parameters
                                                 customHeaderFields:headers
                                                           userName:nil
                                                           password:nil
                                                           delegate:nil];
    
	return r;
}

- (id)resultFromRequest:(BMHTTPRequest *)theRequest {
    
    NSDictionary *parts = [BMStringHelper parametersFromQueryString:theRequest.reply];
    
    if (parts) {
        
        NSString *fmtStreamMapString = parts[@"url_encoded_fmt_stream_map"];
        NSArray *fmtStreamMapArray = [fmtStreamMapString componentsSeparatedByString:@","];
        
        NSMutableDictionary *videoDictionary = [NSMutableDictionary dictionary];
        
        for (NSString *videoEncodedString in fmtStreamMapArray) {
            NSDictionary *videoComponents = [BMStringHelper parametersFromQueryString:videoEncodedString];
            NSString *type = videoComponents[@"type"];
            NSString *signature = videoComponents[@"sig"];
            
            if ([type rangeOfString:@"video/mp4"].length > 0) {
                NSString *url = videoComponents[@"url"];
                url = [NSString stringWithFormat:@"%@&signature=%@", url, signature];
                
                NSString *quality = videoComponents[@"quality"];
                
                if (videoDictionary[quality] == nil) {
                    videoDictionary[quality] = url;
                }
            }
        }
        
        return videoDictionary;
    }
    
    return nil;
}

@end
