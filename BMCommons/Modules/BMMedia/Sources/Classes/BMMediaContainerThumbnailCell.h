//
//  BMMediaContainerThumbnailCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 17/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaContainer.h>
#import <BMCommons/BMObjectPropertyTableViewCell.h>
#import <BMMedia/BMAsyncLoadingMediaThumbnailButton.h>

/**
 Cell to use for displaying a thumbnail for a BMMediaContainer instance.
 */
@interface BMMediaContainerThumbnailCell : BMObjectPropertyTableViewCell

@property(nonatomic, strong) IBOutlet BMAsyncLoadingImageButton *thumbnailImageView;

@end
