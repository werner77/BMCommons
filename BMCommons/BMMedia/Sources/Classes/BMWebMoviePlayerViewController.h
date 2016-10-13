//
//  BMWebMoviePlayerViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 26/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMUICore/BMViewController.h>
#import <BMMedia/BMEmbeddedVideoView.h>

/**
 View controller to show a video from a web URL.
 
 Uses BMEmbeddedVideoView to display the video.
 
 @see BMEmbeddedVideoView.
 */
@interface BMWebMoviePlayerViewController : BMViewController 

@property (nonatomic, readonly) BMEmbeddedVideoView *videoView;
@property (nonatomic, strong) NSString *videoUrl;

@end
