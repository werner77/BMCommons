//
//  BMCameraOverlayView.h
//  BMCommons
//
//  Created by Werner Altewischer on 21/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMReusableObject.h>
#import <BMCommons/BMDraggableButton.h>
#import <BMMedia/BMFlashButton.h>
#import <BMMedia/BMRecordingTimerView.h>

/**
 Class used for a custom camera overlay view for UIImagePickerController in BMCameraController.
 */
@interface BMCameraOverlayView : UIView 

@property (nonatomic, strong) IBOutlet BMFlashButton    *flashLightButton1;
@property (nonatomic, strong) IBOutlet UIButton    *cameraSelectionButton1;
@property (nonatomic, strong) IBOutlet UIButton    *cancelButton1;

@property (nonatomic, strong) IBOutlet BMFlashButton    *flashLightButton2;
@property (nonatomic, strong) IBOutlet UIButton    *cameraSelectionButton2;
@property (nonatomic, strong) IBOutlet UIButton    *cancelButton2;

@property (nonatomic, strong) IBOutlet UIButton    *recordButton;
@property (nonatomic, strong) IBOutlet BMDraggableButton    *switchModeButton;
@property (nonatomic, strong) IBOutlet UIButton    *lastImageButton;

@property (nonatomic, strong) IBOutlet UIView *toolbarContainerView;

@property (nonatomic, strong) IBOutlet UIImageView *toolbar;

@property (nonatomic, strong) IBOutlet UIButton *photoIcon;
@property (nonatomic, strong) IBOutlet UIButton *videoIcon;

@property (nonatomic, strong) IBOutlet BMRecordingTimerView *recordingTimerView;

@property (nonatomic, strong) IBOutlet UIView *irisContainerView;

/**
 Set to YES to disable automatic rotation of the view.
 */
@property (nonatomic, assign) BOOL orientationLocked;

/**
 Adjusts the view for the specified orientiation, either animated or not.
 */
- (void)adjustViewForOrientation:(UIDeviceOrientation)orientation animated:(BOOL)animated;

/**
 Animate the iris in and out.
 */
- (void)animateIris;

- (CGRect)visibleArea;

@end
