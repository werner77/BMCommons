//
//  BMStyleSheet+BMYouTube.m
//  BMCommons
//
//  Created by Werner Altewischer on 6/1/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMStyleSheet+BMYouTube.h"

@implementation BMStyleSheet(BMYouTube)

- (NSString *)youTubeEntryCellIdentifier {
    return @"BMYouTubeEntryCell";
}

- (CGFloat)youTubeEntryCellRowHeight {
    return [BMYouTubeEntryCell heightForValue:nil];
}

- (UIImage *)youTubeLoadingPlaceHolderImage {
    return [UIImage imageNamed:@"BMYouTube.bundle/YouTube-icon.png"];
}

- (UIColor *)youTubeLoadingPlaceHolderBackgroundColor {
    return [UIColor lightGrayColor];
}

@end
