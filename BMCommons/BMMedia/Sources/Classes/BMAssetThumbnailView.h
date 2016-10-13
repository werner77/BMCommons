//
//  Asset.h
//
//  Created by Werner Altewischer on 2/15/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class BMAssetThumbnailView;

@protocol BMAssetThumbnailViewDelegate <NSObject>

@optional

/**
 Return NO to disallow change of selection status requested by the user.
 */
- (BOOL)assetThumbnailView:(BMAssetThumbnailView *)asset shouldChangeSelectionStatus:(BOOL)selected;

/**
 Implement to respond to selection changes.
 */
- (void)assetThumbnailView:(BMAssetThumbnailView *)asset didChangeSelectionStatus:(BOOL)selected;

@end

@interface BMAssetThumbnailView : UIView 

/**
 The asset which the view represents.
 */
@property (nonatomic, strong) ALAsset *asset;

/**
 Delegate.
 */
@property (nonatomic, weak) id<BMAssetThumbnailViewDelegate> delegate;

/**
 If selected a selection overlay image is displayed. 
 
 The delegate methods [BMAssetThumbnailViewDelegate assetThumbnailView:shouldChangeSelectionStatus:] and
 [BMAssetThumbnailViewDelegate assetThumbnailView:didChangeSelectionStatus:] are not called when this method is programmatically invoked, only when the user toggles the selection by tapping the view.
 */
@property (nonatomic, assign) BOOL selected;

@end