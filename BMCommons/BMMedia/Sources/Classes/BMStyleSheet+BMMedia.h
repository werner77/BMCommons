//
//  BMStyleSheet+BMMedia.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/30/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMUICore/BMStyleSheet.h>

@interface BMStyleSheet(BMEmbeddedWebView)

/**
 Loading image shown when a video loads in the full screen media browser.
 */
- (UIImage *)embeddedWebViewLoadingImage;

/**
 Image shown when a video fails loading in the full screen media browser.
 */
- (UIImage *)embeddedWebViewErrorImage;

@end

@interface BMStyleSheet(BMPhotoView)

/**
 Place holder image for the photo view in the fullscreen media browser.
 */
- (UIImage *)photoViewPlaceHolderImage;

@end

@interface BMStyleSheet(BMAssetPicker)

/**
 Color for the summary text in the asset picker of the media library picker.
 */
- (UIColor *)assetPickerSummaryTextColor;

/**
 Font for the summary text in the asset picker of the media library picker.
 */
- (UIFont *)assetPickerSummaryTextFont;

/**
 Background color for the asset picker of the media library picker.
 */
- (UIColor *)assetPickerBackgroundColor;

/**
 The image for the selection overlay of the asset picker.
 */
- (UIImage *)assetPickerSelectionOverlayImage;

@end

@interface BMStyleSheet(BMThumbsView)

/**
 The background color for a thumbnail in the thumbnail view of the full screen media viewer.
 */
- (UIColor *)thumbsViewBackgroundColor;

/**
 The color for the main text of the summary below the thumbnails.
 */
- (UIColor *)thumbsViewSummaryMainTextColor;

/**
 The font for the main text of the summary below the thumbnails.
 */
- (UIFont *)thumbsViewSummaryMainTextFont;

/**
 The color for the sub text of the summary below the thumbnails.
 */
- (UIColor *)thumbsViewSummarySubTextColor;

/**
 The font for the sub text of the summary below the thumbnails.
 */
- (UIFont *)thumbsViewSummarySubTextFont;

@end

@interface BMStyleSheet(YouTube)

/**
 Whether native YouTube mode is enabled by default or not.
 */
- (BOOL)nativeYouTubeModeEnabled;

@end

