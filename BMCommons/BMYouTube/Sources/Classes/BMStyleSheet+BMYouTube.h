//
//  BMStyleSheet+BMYouTube.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/1/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMUICore/BMStyleSheet.h>
#import <BMYouTube/BMYouTubeEntryCell.h>

@interface BMStyleSheet(BMYouTubePicker)

/**
 The cell identifier used by the YouTube picker to load cells for each row.
 */
- (NSString *)youTubeEntryCellIdentifier;

/**
 The row height for the YouTube entry cell.
 */
- (CGFloat)youTubeEntryCellRowHeight;

/**
 The placeholder image for a YouTube thumbnail.
 */
- (UIImage *)youTubeLoadingPlaceHolderImage;

/**
 The background color for the YouTube placeholder thumbnail.
 */
- (UIColor *)youTubeLoadingPlaceHolderBackgroundColor;

@end
