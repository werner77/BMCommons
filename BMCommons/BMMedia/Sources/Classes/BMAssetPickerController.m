//
//  BMImagePickerController.m
//  BMCommons
//
//  Created by Werner Altewischer on 9/9/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAssetPickerController.h>
#import <BMCommons/BMAssetThumbnailView.h>
#import <BMCommons/BMAssetCell.h>
#import <BMCommons/BMAssetTablePickerController.h>
#import <BMCommons/BMAlbumPickerController.h>
#import <BMMedia/BMAssetTablePickerController.h>
#import "ALAsset+BMMedia.h"
#import <BMMedia/BMMedia.h>

@interface BMAssetPickerController()<BMAssetTablePickerControllerDelegate>

@end

@implementation BMAssetPickerController {
    NSMutableDictionary *maxSelectableAssets;
	id<BMAssetPickerControllerDelegate> __weak delegate;
    BOOL allowMixedMediaTypes;
    BMAlbumPickerController *albumController;
}

@synthesize delegate, allowMixedMediaTypes;

- (id)init {
    if ((self = [super init])) {
        BMMediaCheckLicense();
        albumController = [[BMAlbumPickerController alloc] initWithStyle:UITableViewStylePlain];
        albumController.delegate = self;
        [self setViewControllers:@[albumController]];
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    if ([self isViewLoaded]) {
        [self viewDidUnload];
    }
}

- (void)localize {
    [super localize];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:BMUICoreLocalizedString(@"button.title.cancel", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    [albumController.navigationItem setRightBarButtonItem:cancelButton];
}

#pragma mark - Public methods

-(void)cancel {
	if([delegate respondsToSelector:@selector(assetPickerControllerDidCancel:)]) {
		[delegate performSelector:@selector(assetPickerControllerDidCancel:) withObject:self];
	}
}

- (void)setMaxNumberOfSelectableAssets:(NSUInteger)count ofKind:(BMMediaKind)mediaKind {
    if (!maxSelectableAssets) {
        maxSelectableAssets = [NSMutableDictionary new];
    }
    maxSelectableAssets[[NSNumber numberWithInt:(int)mediaKind]] = @(count);
}

- (NSUInteger)maxNumberOfSelectableAssetsOfKind:(BMMediaKind)mediaKind {
    NSNumber *n = maxSelectableAssets[[NSNumber numberWithInt:(int)mediaKind]];
    if (n) {
        return [n unsignedIntegerValue];
    } else {
        return NSUIntegerMax;
    }
}

#pragma mark - BMAssetTablePickerDelegate

- (void)assetTablePicker:(BMAssetTablePickerController *)picker didFinishWithSelectedAssets:(NSArray *)assets {
    if([delegate respondsToSelector:@selector(assetPickerController:didFinishPickingMediaWithAssets:)]) {
		[delegate performSelector:@selector(assetPickerController:didFinishPickingMediaWithAssets:) withObject:self withObject:assets];
	}
}

- (NSUInteger)assetTablePicker:(BMAssetTablePickerController *)picker maxNumberOfSelectableAssetsOfKind:(BMMediaKind)kind {
    return [self maxNumberOfSelectableAssetsOfKind:kind];
}

- (BOOL)assetTablePicker:(BMAssetTablePickerController *)picker allowSelectionOfAsset:(ALAsset *)asset {
    
    BMMediaKind kind = [asset bmMediaKind];
    NSUInteger selectedVideoAssets = [picker numberOfSelectedAssetsOfKind:BMMediaKindVideo];
    NSUInteger selectedPictureAssets = [picker numberOfSelectedAssetsOfKind:BMMediaKindPicture];
    NSUInteger totalSelectedAssets = selectedVideoAssets + selectedPictureAssets;
    
    NSUInteger maxVideos = [self maxNumberOfSelectableAssetsOfKind:BMMediaKindVideo];
    NSUInteger maxPictures = [self maxNumberOfSelectableAssetsOfKind:BMMediaKindPicture];
    NSUInteger maxTotal = [self maxNumberOfSelectableAssetsOfKind:BMMediaKindUnknown];
    
    BOOL ret = YES;
    
    if ((selectedVideoAssets >= maxVideos && kind == BMMediaKindVideo) ||
        (selectedPictureAssets >= maxPictures && kind == BMMediaKindPicture) ||
        totalSelectedAssets >= maxTotal ||
        (!self.allowMixedMediaTypes && selectedPictureAssets > 0 && kind == BMMediaKindVideo) ||
        (!self.allowMixedMediaTypes && selectedVideoAssets > 0 && kind == BMMediaKindPicture)) {
        ret = NO;
    }
    
    if (!ret && [delegate respondsToSelector:@selector(assetPickerControllerReachedMaxSelectableAssets:)]) {
        [delegate assetPickerControllerReachedMaxSelectableAssets:self];
    }
    
    if (ret && [delegate respondsToSelector:@selector(assetPickerController:shouldAllowSelectionOfAsset:)]) {
        ret = [delegate assetPickerController:self shouldAllowSelectionOfAsset:asset];
    }
    
    return ret;
}

@end
