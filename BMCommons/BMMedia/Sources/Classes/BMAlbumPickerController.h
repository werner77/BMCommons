//
//  AlbumPickerController.h
//
//  Created by Werner Altewischer on 2/15/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMMedia/BMAssetTablePickerController.h>
#import <BMUICore/BMTableViewController.h>

/**
 Controller to choose a photo album to pick media from.
 */
@interface BMAlbumPickerController : BMTableViewController

/**
 Delegate to respond to selection changes.
 */
@property (nonatomic, weak) id<BMAssetTablePickerControllerDelegate> delegate;

/**
 The array of ALAssetsGroup instances that were retrieved.
 */
@property (nonatomic, readonly) NSArray *assetGroups;

@end

