//
//  BMImagePickerController.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/26/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMCommons/BMViewController.h>

@class BMImagePickerController;

/**
 Extended delegate protocol for BMImagePickerController.
 */
@protocol BMImagePickerControllerDelegate <UIImagePickerControllerDelegate>

@optional
- (void)imagePickerControllerWillAppear:(BMImagePickerController *)controller;
- (void)imagePickerControllerDidAppear:(BMImagePickerController *)controller;
- (void)imagePickerControllerWillDisappear:(BMImagePickerController *)controller;
- (void)imagePickerControllerDidDisappear:(BMImagePickerController *)controller;

@end

/**
 Custom UIImagePickerController with support for more delegate messages.
 */
@interface BMImagePickerController : UIImagePickerController

@property (nonatomic, readonly) BMViewState viewState;

- (CGFloat)scaleFactorForCameraCaptureMode:(UIImagePickerControllerCameraCaptureMode)cameraCaptureMode;
- (void)setScaleFactor:(CGFloat)scaleFactor forCameraCaptureMode:(UIImagePickerControllerCameraCaptureMode)cameraCaptureMode;

@end
