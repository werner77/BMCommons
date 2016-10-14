//
//  BMMediaRollThumbnailCell.h
//  BMCommons
//
//  Created by Werner Altewischer on 27/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMMedia/BMMediaContainerThumbnailCell.h>

/**
 Cell for use in a media roll controlled by a BMMediaRollController.
 
 This is a rotated table view cell for use in a BMMediaRollCell containing a counter rotated UITableView. The cell takes care of asynchronous loading of the media thumbnail and maintaining the proper dimensions for the thumbnail view.
 */
@interface BMMediaRollThumbnailCell : BMMediaContainerThumbnailCell

@end
