//
//  BMYouTubeHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/15/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMMediaHelper.h>
#import <BMCommons/BMRegexKitLite.h>
#import <BMCommons/BMServiceManager.h>
#import <BMMedia/BMGetYouTubeStreamInfoService.h>
#import <BMCommons/BMBlockServiceDelegate.h>

@implementation BMMediaHelper
    
+ (NSString *)extractedYouTubeVideoIdFromUrl:(NSString *)theUrl {
    
    NSString *regex = @".*(?:youtu.be\\/|v\\/|u\\/\\w\\/|embed\\/|watch\\?v=)([^#\\&\\?]*).*";
    
    NSString *videoId = [theUrl stringByMatching:regex capture:1];
    
    return videoId;
}

+ (NSString *)retrieveDirectYouTubeUrlForVideoId:(NSString *)videoId withSuccess:(void (^) (NSString *theUrl))success failure:(void (^)(NSError *theError))failure {
   BMGetYouTubeStreamInfoService *youTubeService = [[BMGetYouTubeStreamInfoService alloc] init];
    youTubeService.backgroundService = YES;
    youTubeService.videoId = videoId;
    return [[BMServiceManager sharedInstance] performService:youTubeService withDelegate:[BMBlockServiceDelegate delegateWithSuccess:^(NSDictionary *result) {
        NSString *theUrl = result[BMYouTubeQualityMedium];
        success(theUrl);
    } failure:^(BOOL cancelled, NSError *error) {
        failure(error);
    }]];
}

+ (void)cancelRetrievingDirectYouTubeUrl:(NSString *)loadingIdentifier {
    [[BMServiceManager sharedInstance] cancelServiceWithInstanceIdentifier:loadingIdentifier];
}

@end
