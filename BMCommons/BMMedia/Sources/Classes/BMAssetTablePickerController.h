//
//  AssetTablePicker.h
//
//  Created by Werner Altewischer on 2/15/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <BMUICore/BMTableViewController.h>
#import <BMMedia/BMMediaContainer.h>

@class BMAssetTablePickerController;

/**
 Delegate protocol for the BMAssetTablePickerController to respond to selection events.
 */
@protocol BMAssetTablePickerControllerDelegate <NSObject>

/**
 Implement to handle the selected ALAsset instances and optionally dismiss the picker.
 */
- (void)assetTablePicker:(BMAssetTablePickerController *)picker didFinishWithSelectedAssets:(NSArray *)assets;

/**
 Return the max number of selectable asset instances for the specified BMMediaKind.
 */
- (NSUInteger)assetTablePicker:(BMAssetTablePickerController *)picker maxNumberOfSelectableAssetsOfKind:(BMMediaKind)kind;

/**
 Return YES or NO to allow or disallow selection of the specified ALAsset instance.
 */
- (BOOL)assetTablePicker:(BMAssetTablePickerController *)picker allowSelectionOfAsset:(ALAsset *)asset;

@end

/**
 Picker view for multi-selection of ALAsset instances from a specific ALAssetsGroup.
 */
@interface BMAssetTablePickerController : BMTableViewController

/**
 Delegate tot respond to changes in selection.
 */
@property (nonatomic, weak) id<BMAssetTablePickerControllerDelegate> delegate;

/**
 The asset group for which the assets to select should be presented.
 */
@property (nonatomic, strong) ALAssetsGroup *assetGroup;

/**
 The array of selected ALAsset instances.
 */
@property (nonatomic, readonly) NSArray *selectedAssets;

- (NSUInteger)numberOfSelectedAssets;
- (NSUInteger)numberOfSelectedAssetsOfKind:(BMMediaKind)mediaKind;

@end