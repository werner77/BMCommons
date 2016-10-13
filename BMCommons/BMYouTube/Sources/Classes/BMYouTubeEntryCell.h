//
//  BMYouTubeEntryCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 24/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMUICore/BMObjectPropertyTableViewCell.h>
#import <BMMedia/BMEmbeddedVideoView.h>

@class BMObjectPropertyTableViewCell;

/**
 UITableView cell to represent a YouTube video entry.
 */
@interface BMYouTubeEntryCell : BMObjectPropertyTableViewCell

@property (nonatomic, strong) IBOutlet BMEmbeddedVideoView *thumbnailView;
@property (nonatomic, strong) IBOutlet UILabel *likesLabel;
@property (nonatomic, strong) IBOutlet UILabel *viewsLabel;
@property (nonatomic, strong) IBOutlet UILabel *userLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;
@property (nonatomic, strong) IBOutlet UILabel *uploadDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;

@end
