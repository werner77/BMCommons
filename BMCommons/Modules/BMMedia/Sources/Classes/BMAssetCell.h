//
//  AssetCell.h
//
//  Created by Werner Altewischer on 2/15/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMMedia/BMAssetThumbnailView.h>

/** 
 UITableViewCell with multiple thumbnails arranged horizontally depicting ALAsset instances.
 */
@interface BMAssetCell : UITableViewCell

/**
 Returns the number of thumbnails that can width the specified width.
 */
+ (NSInteger)numberOfThumbnailsForWidth:(CGFloat)width;

/**
 Initializer.
 */
- (id)initWithReuseIdentifier:(NSString*)identifier numberOfThumbnails:(NSInteger)numberOfThumbnails;

/**
 Array of BMAssetThumbnailView instances.
 */
@property (nonatomic,readonly) NSArray *thumbnailViews;

@end
