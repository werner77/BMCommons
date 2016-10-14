//
//  BMMediaPickerController.h
//  BMCommons
//
//  Created by Werner Altewischer on 14/07/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaContainer.h>
#import <BMCommons/BMStyleSheet.h>

@class BMMediaPickerController;

/**
 Delegate protocol for BMMediaPickerController.
 */
@protocol BMMediaPickerControllerDelegate<NSObject>

/**
 Sent when the media picker is dismissed. 
 
 The array of media contains the BMMediaContainer instances that were selected.
 
 @see [BMMediaPickerController dismiss]
 */
- (void)mediaPickerControllerWasDismissed:(BMMediaPickerController *)controller withMedia:(NSArray *)media;

/**
 Sent when the media picker is cancelled.

 @see [BMMediaPickerController cancel]
 */
- (void)mediaPickerControllerWasCancelled:(BMMediaPickerController *)controller;

/**
 Should return a new autoreleased instance of BMVideoContainer for use to store the information when a video is selected/recorded.
 */
- (id <BMVideoContainer>)videoContainerForMediaPickerController:(BMMediaPickerController *)controller;

/**
 Should return a new autoreleased instance of BMPictureContainer for use to store the information when a picture is selected/taken.
 */
- (id <BMPictureContainer>)pictureContainerForMediaPickerController:(BMMediaPickerController *)controller;

@optional

/**
 Called when the max number of selectable media was reached. 
 
 Use this to show an appropriate alert for example.
 */
- (void)mediaPickerControllerReachedMaxSelectableMedia:(BMMediaPickerController *)controller;

/**
 Called when the max duration for a video was reached. 
 
 Use this to show an appropriate alert for example.
 */
- (void)mediaPickerControllerReachedMaxDuration:(BMMediaPickerController *)controller;

/**
 Called to determine whether the specified item may be selected. 
 
 Default is YES when not implemented. You could implement this to not allow selection
 for items that are already selected so they are disabled for reselection.
 */
- (BOOL)mediaPickerController:(BMMediaPickerController *)controller shouldAllowSelectionOfMedia:(id <BMMediaContainer>)mediaItem;

/**
 Implement to customize the view controller before it is displayed.
 
 Most of the time the viewcontroller to be presented is a UINavigationController.
 */
- (void)mediaPickerController:(BMMediaPickerController *)controller willPresentViewController:(UIViewController *)vc;

@end

/**
 Abstract super class for concrete implementations for picking BMMediaContainer instances from different sources.
 */
@interface BMMediaPickerController : NSObject<BMMediaContainerDelegate>

/**
 The delegate.
 */
@property (nonatomic, weak) id <BMMediaPickerControllerDelegate> delegate;

/**
 The parent view controller from which the picker was presented.
 */
@property (weak, nonatomic, readonly) UIViewController *parentViewController;

/**
 The root view controller that is used to display the picker.
 */
@property (weak, nonatomic, readonly) UIViewController *rootViewController;

/**
 The array of selected media items.
 */
@property (strong, nonatomic, readonly) NSArray *media;

/**
 The max number of selectable pictures, default is NSUIntegerMax.
 */
@property (nonatomic, assign) NSUInteger maxSelectablePictures;

/**
 The max number of selectable videos, default is NSUIntegerMax.
 */
@property (nonatomic, assign) NSUInteger maxSelectableVideos;

/**
 The max number of total selectable media items, default is NSUIntegerMax.
 */
@property (nonatomic, assign) NSUInteger maxSelectableMedia;

/**
 Whether to allow mixed selection of pictures and videos or just one kind.
 */
@property (nonatomic, assign) BOOL allowMixedMediaTypes;

/**
 The max duration for a video in case of video selection.
 */
@property (nonatomic, assign) NSTimeInterval maxDuration;

/**
 Stylesheet to use when the picker is presented.
 
 Set this before calling presentFromViewController: or presentFromViewController:withTransitionStyle:
 */
@property (nonatomic, strong) BMStyleSheet *styleSheet;

/**
 Present the picker modally from the specified view controller using the specified transition style.
 */
- (BOOL)presentFromViewController:(UIViewController *)vc withTransitionStyle:(UIModalTransitionStyle)transitionStyle;

/**
 Calls presentFromViewController:withTransitionStyle: where transitionStyle is UIModalTransitionStyleCoverVertical.
 */
- (BOOL)presentFromViewController:(UIViewController *)vc;

/**
 Dismisses the picker with the selected media.
 
 Calls [BMMediaPickerControllerDelegate mediaPickerControllerWasDismissed:withMedia:] with the selected media.
 */
- (void)dismiss;

/**
 Cancels the picker. 
 
 The controller will be dismissed with no selected media. Calls [BMMediaPickerControllerDelegate mediaPickerControllerWasCancelled]
 @see dismiss
 */
- (void)cancel;

/**
 Selected number of videos.
 */
- (NSUInteger)videoCount;

/**
 Selected number of pictures.
 */
- (NSUInteger)pictureCount;

/**
 Total selected number of medias.
 */
- (NSUInteger)mediaCount;

/**
 Adds a media item to the selection.
 */
- (void)addMedia:(id <BMMediaContainer>)m;

/**
 Removes a media item from the selection.
 */
- (void)removeMedia:(id <BMMediaContainer>)m;

@end

/**
 Protected methods for sub classes to override or interact with.
 */
@interface BMMediaPickerController(Protected)

- (void)maxSelectableMediaReached;
- (void)maxDurationReached;
- (BOOL)checkSelectionLimitsForNewMediaOfKind:(BMMediaKind)kind;
- (void)dismissWithCancel:(BOOL)cancel;

@end

