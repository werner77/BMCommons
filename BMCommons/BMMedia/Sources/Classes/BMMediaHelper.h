//
//  BMYouTubeHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/15/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Helper class for YouTube videos.
 */
@interface BMMediaHelper : NSObject
    
/**
 Extracts a YouTube video ID from the specified URL. 
 
 Returns nil if no video ID could be parsed.
 */
+ (NSString *)extractedYouTubeVideoIdFromUrl:(NSString *)theUrl;

/**
 Tries to retrieve the direct streaming URL for the specified YouTube video ID.
 */
+ (NSString *)retrieveDirectYouTubeUrlForVideoId:(NSString *)videoId withSuccess:(void (^) (NSString *theUrl))success failure:(void (^)(NSError *theError))failure;

/**
 Cancels loading of a direct YouTube stream URL with a previously acquired identifier.
 
 @see retrieveDirectYouTubeUrlForVideoId:withSuccess:failure:
 */
+ (void)cancelRetrievingDirectYouTubeUrl:(NSString *)loadingIdentifier;

@end
