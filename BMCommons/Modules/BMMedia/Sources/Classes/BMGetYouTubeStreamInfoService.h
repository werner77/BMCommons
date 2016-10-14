//
//  BMYouTubeGetVideoInfoService.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/20/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMHTTPService.h>

///---------------------------------------------------------------------------------------
/// @name Keys of the dictionary returned by BMGetYouTubeStreamInfoService
///---------------------------------------------------------------------------------------

/**
 @constant YouTube high quality stream (hd) key.
 */
extern NSString *const BMYouTubeQualityHigh;

/**
 @constant YouTube medium quality stream key.
 */
extern NSString *const BMYouTubeQualityMedium;

/**
 @constant YouTube low quality stream key.
 */
extern NSString *const BMYouTubeQualityLow;


/**
 Service for retrieving the direct stream info for a YouTube video by videoId.
 
 This service uses a non-disclosed method to retrieve the native YouTube stream info for the specified ID. The return value returned to the delegate by [BMServiceDelegate service:succeededWithResult:] is a NSDictionary with as key a string denoting the quality of the stream and as value a string containing the URL for that stream. This URL may be fed to a MPMoviePlayerController for example to stream the video directly without having to use a UIWebView with the ordinary http YouTube URL.
 
 The keys of the dictionary are defined by the constants BMYouTubeQualityHigh, BMYouTubeQualityMedium and BMYouTubeQualityLow.
 */
@interface BMGetYouTubeStreamInfoService : BMHTTPService

/**
 The YouTube videoId for which to retrieve the stream info. 
 
 This is the ID you see in a typical YouTube URL such as http://www.youtube.com/watch?v=k4ixAfJ1LuI
 */
@property (nonatomic, strong) NSString *videoId;

@end

