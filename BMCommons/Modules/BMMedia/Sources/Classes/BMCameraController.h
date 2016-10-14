//
//  BMCameraViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 21/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaPickerController.h>

@class BMCameraController;
@class BMCameraOverlayView;

/**
 Delegate protocol for BMCameraController.
 */
@protocol BMCameraControllerDelegate <BMMediaPickerControllerDelegate>

@optional
/**
 Sent when the user touched the last media item in the lower left corner. 
 
 Use this for example to show a preview of all the media recorded.
 */
- (void)cameraController:(BMCameraController *)controller didSelectMedia:(id <BMMediaContainer>)media;

@end

/**
 Media picker to record multiple pictures/videos in one go using the device's camera.
 */
@interface BMCameraController : BMMediaPickerController

/**
 Whether to save the recorded media (picture/video) to the media roll. Default is NO.
 */
@property (nonatomic, assign) BOOL saveToCameraRoll;

/**
 Reference to the image picker controller used to display the camera.
 */
@property (nonatomic, readonly) UIImagePickerController *imagePickerController;

@end
