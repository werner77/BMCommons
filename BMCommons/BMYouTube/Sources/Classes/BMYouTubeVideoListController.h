//
//  BMYouTubeVideoListController.h
//  BMCommons
//
//  Created by Werner Altewischer on 24/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMUICore/BMServiceModelTableViewController.h>
#import <GData/GTMOAuth2Authentication.h>
#import <GData/GDataEntryYouTubeVideo.h>

@class BMYouTubeVideoListController;

@protocol BMYouTubeVideoListControllerDelegate <NSObject>

@optional
/**
 Return NO to disallow selection of the specified video entry.
 
 Default is YES.
 */
- (BOOL)youTubeVideoListController:(BMYouTubeVideoListController *)vc shouldSelectVideo:(GDataEntryYouTubeVideo *)video;

@end

@interface BMYouTubeVideoListController : BMServiceModelTableViewController

@property (nonatomic, weak) id <BMYouTubeVideoListControllerDelegate> delegate;

/**
 The YouTube developer key to access the YouTube API.
 */
@property (nonatomic, strong) NSString *developerKey;

/**
 The Google authentication object.
 */
@property (nonatomic, strong) GTMOAuth2Authentication *authentication;

/**
 Whether to use native mode (direct mp4 streams) or not.
 */
@property (nonatomic, assign) BOOL useNativeMode;

/**
 The loaded entries.
 
 Entries are instances of GDataEntryYouTubeVideo.
 */
- (NSArray *)entries;

/**
 The selected entries.
 
 Entries are instances of GDataEntryYouTubeVideo.
 */
- (NSArray *)selectedEntries;


@end
