//
//  AssetCell.m
//
//  Created by Werner Altewischer on 2/15/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMAssetCell.h"
#import <BMMedia/BMMedia.h>

#define THUMBNAIL_DIMENSION 75

@implementation BMAssetCell {
	NSMutableArray *thumbnailViews;
}

@synthesize thumbnailViews;

+ (NSInteger)numberOfThumbnailsForWidth:(CGFloat)width {
    return ((NSInteger)width)/(THUMBNAIL_DIMENSION + 2);
}

- (id)initWithReuseIdentifier:(NSString*)_identifier numberOfThumbnails:(NSInteger)numberOfThumbnails {
	if((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier])) {
        BMMediaCheckLicense();
		thumbnailViews = [NSMutableArray new];
        for (int i =0; i < numberOfThumbnails; ++i) {
            BMAssetThumbnailView *assetView = [[BMAssetThumbnailView alloc] initWithFrame:CGRectMake(0,0,THUMBNAIL_DIMENSION,THUMBNAIL_DIMENSION)];
            [thumbnailViews addObject:assetView];
            [self addSubview:assetView];
        }
	}
	return self;
}

- (void)layoutSubviews {
    NSInteger totalWidth = self.frame.size.width;
    NSInteger numberOfThumbnails = self.thumbnailViews.count;
    NSInteger totalSpace = totalWidth - numberOfThumbnails * THUMBNAIL_DIMENSION;
    NSInteger spacePerThumbnail = MAX(2, totalSpace / (numberOfThumbnails + 1));
    //NSInteger spacePerThumbnail = 4;
    NSInteger initialOffset = (totalSpace - (spacePerThumbnail * (numberOfThumbnails - 1)))/2;
    
	CGRect theFrame = CGRectMake(initialOffset, 2, THUMBNAIL_DIMENSION, THUMBNAIL_DIMENSION);
	for(BMAssetThumbnailView *assetView in self.thumbnailViews) {
		[assetView setFrame:theFrame];
		theFrame.origin.x = theFrame.origin.x + theFrame.size.width + spacePerThumbnail;
	}
}


@end
