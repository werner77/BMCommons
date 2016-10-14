//
//  BMAssetPickerController.h
//  BMCommons
//
//  Created by Werner Altewischer on 9/9/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <BMCommons/BMNavigationController.h>
#import <BMMedia/BMMediaContainer.h>

@class BMAssetPickerController;

/**
 Delegate protocol for BMAssetPickerController.
 */
@protocol BMAssetPickerControllerDelegate<UINavigationControllerDelegate>

/**
 Implement to handle the selected ALAsset instances and typically dismiss the picker.
 */
- (void)assetPickerController:(BMAssetPickerController *)picker didFinishPickingMediaWithAssets:(NSArray *)assets;

/**
 Implement to handle a cancel event, typically by dismissing the picker.
 */
- (void)assetPickerControllerDidCancel:(BMAssetPickerController *)picker;

@optional

/**
 Implement to act on the event where the max selectable assets are reached, e.g. by showing an alert.
 */
- (void)assetPickerControllerReachedMaxSelectableAssets:(BMAssetPickerController *)picker;

/**
 Return YES to allow selection of the specified asset (default) or NO otherwise.
 */
- (BOOL)assetPickerController:(BMAssetPickerController *)picker shouldAllowSelectionOfAsset:(ALAsset *)asset;

@end

/**
 Controller for presenting BMAlbumPickerController and subsequent BMAssetTablePickerController.
 */
@interface BMAssetPickerController : BMNavigationController

/**
 The delegate.
 */
@property (nonatomic, weak) id<BMAssetPickerControllerDelegate> delegate;

/**
 Whether or not to allow mixing of media types in the selection, e.g. both videos and pictures in the same selection set.
 */
@property (nonatomic, assign) BOOL allowMixedMediaTypes;

/**
 Cancels the picker.
 */
- (void)cancel;

/**
 Sets the max number of selectable assets for the specified BMMediaKind.
 */
- (void)setMaxNumberOfSelectableAssets:(NSUInteger)count ofKind:(BMMediaKind)mediaKind;

- (NSUInteger)maxNumberOfSelectableAssetsOfKind:(BMMediaKind)mediaKind;

@end


