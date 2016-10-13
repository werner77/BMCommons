//
//  BMYouTubeListCompatibleVideosService.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/20/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCompositeService.h>
#import <BMCommons/BMYouTubeService.h>

/**
 Wraps a YouTube service to list videos that are compatible with direct streaming mode.
 */
@interface BMYouTubeListDirectStreamableVideosService : BMCompositeService

@property (nonatomic, strong) BMYouTubeService *wrappedService;
@property (nonatomic, readonly) NSUInteger numberOfEntries;

@end
