//
//  BMStyleSheet+BMMedia.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/30/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMStyleSheet+BMMedia.h>
#import <BMCommons/BMURLCache.h>
#import <BMMedia/BMMedia.h>

@implementation BMStyleSheet(BMEmbeddedWebView)

- (UIImage *)embeddedWebViewLoadingImage {
    return nil;
}

- (UIImage *)embeddedWebViewErrorImage {
    return BMIMAGE(@"bundle://BMUICore.bundle/no-video.png");
}

@end

@implementation BMStyleSheet(BMPhotoView)

- (UIImage *)photoViewPlaceHolderImage {
    return BMIMAGE(@"bundle://BMUICore.bundle/default-no-image.png");
}

@end

@implementation BMStyleSheet(BMAssetPicker)

- (UIColor *)assetPickerSummaryTextColor {
    return [UIColor grayColor];
}

- (UIFont *)assetPickerSummaryTextFont {
    return [UIFont systemFontOfSize:17.0];
}

- (UIColor *)assetPickerBackgroundColor {
    return [UIColor whiteColor];
}

- (UIImage *)assetPickerSelectionOverlayImage {
    return [UIImage imageNamed:@"BMMedia.bundle/Overlay.png"];
}

@end

@implementation BMStyleSheet(BMThumbsView)

- (UIColor *)thumbsViewBackgroundColor {
    return nil;
}

- (UIColor *)thumbsViewSummaryMainTextColor {
    return nil;
}

- (UIFont *)thumbsViewSummaryMainTextFont {
    return nil;
}

- (UIColor *)thumbsViewSummarySubTextColor {
    return nil;
}

- (UIFont *)thumbsViewSummarySubTextFont {
    return nil;
}

@end

@implementation BMStyleSheet(YouTube)

- (BOOL)nativeYouTubeModeEnabled {
    return NO;
}

@end


