//
//  BMCameraViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 21/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCameraController.h>
#import <BMMedia/BMMedia.h>
#import <BMCommons/BMDialogHelper.h>
#import <BMCommons/BMViewFactory.h>
#import <BMCommons/BMImageHelper.h>
#import <BMCommons/UIView+BMCommons.h>
#import <BMCommons/UIButton+BMCommons.h>
#import <BMCommons/BMPictureSaveOperation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <BMCommons/BMVideoSaveOperation.h>
#import <QuartzCore/QuartzCore.h>
#import <BMCommons/BMApplicationHelper.h>
#import <BMCommons/BMBusyView.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <BMCommons/BMEnumeratedValue.h>
#import <BMCommons/BMCameraOverlayView.h>
#import <BMMedia/BMMediaContainer.h>
#import <BMMedia/BMImagePickerController.h>
#import <BMCommons/BMOperationQueue.h>

@interface BMCameraController() <BMImagePickerControllerDelegate, UINavigationControllerDelegate, BMOperationQueueDelegate, BMRecordingTimerViewDelegate>

@end

@interface BMCameraController(Private)

- (void)updateFlashButtonForState;
- (void)updateCameraDeviceButtonForState;
- (void)updateCameraModeButtonForState;
- (void)updateRecordingButtonForState;
- (void)updateLastImageButtonWithImage:(UIImage *)theImage animated:(BOOL)animated;
- (void)startAnimationWithImage:(UIImage *)theImage;
- (void)addPicture:(UIImage *)image withOrientation:(BMMediaOrientation)orientation andMetaData:(NSDictionary *)metaData;
- (void)addVideo:(NSURL *)mediaUrl withOrientation:(BMMediaOrientation)orientation andMetaData:(NSDictionary *)metaData;
- (void)scheduleOperation:(BMMediaSaveOperation *)operation;
- (UIImage *)stretchedImageNamed:(NSString *)imageName;
- (BMOperationQueue *)operationQueue;
- (void)hideButtons;
- (void)showButtons;

@end


@implementation BMCameraController {
	BMImagePickerController *imagePickerController;
	BOOL recording;
	BMCameraOverlayView *overlayView;
	NSMutableArray *scheduledOperations;
    UIImageView *irisImageView;
    BOOL saveToCameraRoll;
    UIInterfaceOrientation recordedOrientation;
    id <BMMediaContainer> selectedMedia;
}

@synthesize saveToCameraRoll;
@synthesize imagePickerController;

#pragma mark -
#pragma mark Initialization and deallocation

- (id)init {
	if ((self = [super init])) {
		scheduledOperations = [NSMutableArray new];
		BMOperationQueue *operationQueue = self.operationQueue;
		[operationQueue addDelegate:self];
	}
	return self;
}

- (void)dealloc {
	BMOperationQueue *operationQueue = self.operationQueue;
	[operationQueue removeDelegate:self];
    imagePickerController.delegate = nil;
	[imagePickerController dismissViewControllerAnimated:NO completion:nil];
	BM_RELEASE_SAFELY(imagePickerController);
	BM_RELEASE_SAFELY(scheduledOperations);
}

#pragma mark -
#pragma mark Main methods

- (BOOL)presentFromViewController:(UIViewController *)vc withTransitionStyle:(UIModalTransitionStyle)transitionStyle {
    BOOL ret = NO;
	if (!imagePickerController) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			
			[super presentFromViewController:vc withTransitionStyle:transitionStyle];
			
			imagePickerController = [[BMImagePickerController alloc] init];
			imagePickerController.delegate = self;
            imagePickerController.modalTransitionStyle = transitionStyle;
			imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
			imagePickerController.allowsEditing = NO;
            
            
			BMViewFactory *viewFactory = [[BMViewFactory alloc] initWithBundle:[BMMedia bundle]];
				
			overlayView = (BMCameraOverlayView *)[viewFactory viewFromNib:@"CameraOverlayView"];
            overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            overlayView.recordingTimerView.delegate = self;
            overlayView.recordingTimerView.warningTimeThreshold = 30.0;
            overlayView.recordingTimerView.criticalTimeThreshold = 10.0;
            
            [overlayView.toolbar setImage:[self stretchedImageNamed:@"BMMedia.bundle/PLCameraButtonBarSilver.png"]];
            [overlayView.recordButton setBackgroundImage:[self stretchedImageNamed:@"BMMedia.bundle/PLCameraButtonSilver.png"] forState:UIControlStateNormal];
            [overlayView.recordButton setBackgroundImage:[self stretchedImageNamed:@"BMMedia.bundle/PLCameraButtonSilverPressed.png"] forState:UIControlStateHighlighted];

            [overlayView.recordButton bmSetTarget:self action:@selector(onRecord:)];
            [overlayView.cancelButton1 bmSetTarget:self action:@selector(onCancel:)];
            [overlayView.cameraSelectionButton1 bmSetTarget:self action:@selector(onSelectCamera:)];
            [overlayView.flashLightButton1 addTarget:self action:@selector(onFlashLight:) forControlEvents:UIControlEventValueChanged];
            [overlayView.flashLightButton1 addTarget:self action:@selector(onToggleFlashLightExpansion:) forControlEvents:UIControlEventEditingDidBegin | UIControlEventEditingDidEnd];

            [overlayView.cancelButton2 bmSetTarget:self action:@selector(onCancel:)];
            [overlayView.cameraSelectionButton2 bmSetTarget:self action:@selector(onSelectCamera:)];
            [overlayView.flashLightButton2 addTarget:self action:@selector(onFlashLight:) forControlEvents:UIControlEventValueChanged];
            [overlayView.flashLightButton2 addTarget:self action:@selector(onToggleFlashLightExpansion:) forControlEvents:UIControlEventEditingDidBegin | UIControlEventEditingDidEnd];
            [overlayView.switchModeButton addTarget:self action:@selector(onSwitchMode:) forControlEvents:UIControlEventValueChanged];

            [overlayView.lastImageButton bmSetTarget:self action:@selector(onSelectLastImage:)];
			
			imagePickerController.showsCameraControls = NO;
			imagePickerController.cameraOverlayView = overlayView;
            
            if (BMIsIPhone5()) {
                [imagePickerController setScaleFactor:1.42 forCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
            }
			
            [self showButtons];
			[self hideButtons];
			
			NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            
            if (self.maxSelectableVideos == 0) {
                //Don't support video
                availableMediaTypes = [NSMutableArray arrayWithArray:availableMediaTypes];
                [(NSMutableArray *)availableMediaTypes removeObject:(NSString *)kUTTypeMovie];
            }
            
            imagePickerController.mediaTypes = availableMediaTypes;
            
            if ([self.delegate respondsToSelector:@selector(mediaPickerController:willPresentViewController:)]) {
                [self.delegate mediaPickerController:self willPresentViewController:imagePickerController];
            }
			
            [vc presentViewController:imagePickerController animated:YES completion:nil];
            
            ret = YES;
            
		} else {
			[BMDialogHelper alertWithTitle:BMMediaLocalizedString(@"alert.title.sorry", @"Sorry") message:BMMediaLocalizedString(@"camera.alert.message.notavailable", @"No camera available on this device") delegate:nil];
		}
	}
    return ret;
}		


- (void)dismissWithCancel:(BOOL)cancel {
	//Wait for all the media to complete saving
	if (scheduledOperations.count > 0) {
		CGFloat totalCount = scheduledOperations.count;

        BMBusyView *busyView = [BMBusyView showBusyViewAnimated:YES];

		NSString *message = BMMediaLocalizedString(@"camera.busyview.savingdata", @"Saving data...");
        busyView.label.text = message;
        [busyView setProgress:0.0];
		while (scheduledOperations.count > 0) {
			[BMApplicationHelper doEvents];
			busyView.label.text = message;
            [busyView setProgress:(1.0 - (scheduledOperations.count/totalCount))];
		}
		[BMBusyView hideBusyViewAnimated:YES];
		[BMApplicationHelper doEvents];
	}
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    imagePickerController.delegate = nil;
	BM_RELEASE_SAFELY(imagePickerController);
	[super dismissWithCancel:cancel];
}

- (UIViewController *)rootViewController {
    return imagePickerController;
}

#pragma mark -
#pragma mark MediaContainerDelegate

- (void)mediaContainerWasDeleted:(id <BMMediaContainer>)mediaContainer {
    [super mediaContainerWasDeleted:mediaContainer];
    id <BMMediaContainer> lastMedia = [self.media lastObject];
	[self updateLastImageButtonWithImage:lastMedia.thumbnailImage animated:YES];
}
		
#pragma mark -
#pragma mark UIImagePickerControllerDelegate implementation
		
		
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	recording = NO;
	[self updateRecordingButtonForState];
    [self updateCameraDeviceButtonForState];
    
    BMMediaOrientation theOrientation = [BMMedia mediaOrientationFromInterfaceOrientation:recordedOrientation];
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    NSDictionary *metaData = info[UIImagePickerControllerMediaMetadata];
    if ([mediaType isEqual:(NSString*)kUTTypeMovie]) {
        // deal with the movie
        NSURL *mediaUrl = info[UIImagePickerControllerMediaURL];
		[self addVideo:mediaUrl withOrientation:theOrientation andMetaData:metaData];
    } else {
		//Picture
		UIImage *image = info[UIImagePickerControllerOriginalImage];
		[self addPicture:image withOrientation:theOrientation andMetaData:metaData];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismiss];
}

- (void)imagePickerControllerWillAppear:(BMImagePickerController *)controller {
    
}

- (void)imagePickerControllerDidAppear:(BMImagePickerController *)controller {
    //Show buttons
    if (BMOSVersionIsAtLeast(@"7.0")) {
        [self performSelector:@selector(showButtonsConditionally) withObject:nil afterDelay:0.2];
    } else {
        [self performSelector:@selector(showButtonsConditionally) withObject:nil afterDelay:1.0];
    }
    
}

- (void)imagePickerControllerWillDisappear:(BMImagePickerController *)controller {
    //Hide buttons
    [self hideButtons];
}

- (void)imagePickerControllerDidDisappear:(BMImagePickerController *)controller {
    
}


#pragma mark -
#pragma mark BMRecordingTimerViewDelegate

- (void)recordingTimerViewReachedMaxDuration:(id)view {
    [self onRecord:nil];
}

#pragma mark -
#pragma mark Actions

- (IBAction)onCancel:(UIButton *)sender {
	[imagePickerController.delegate imagePickerControllerDidCancel:imagePickerController];	
}

- (IBAction)onRecord:(UIButton *)sender {
    BMMediaKind kind = (imagePickerController.cameraCaptureMode == UIImagePickerControllerCameraCaptureModePhoto) ? BMMediaKindPicture : BMMediaKindVideo;
    
    if ([self checkSelectionLimitsForNewMediaOfKind:kind]) {
        if (imagePickerController.cameraCaptureMode == UIImagePickerControllerCameraCaptureModePhoto) {
            [overlayView animateIris];
            [imagePickerController takePicture];
            recordedOrientation = imagePickerController.interfaceOrientation;
        } else if (recording) {
            [imagePickerController stopVideoCapture];
            recording = NO;
        } else {
            overlayView.recordingTimerView.maxTime = self.maxDuration;
            if (self.maxDuration > 0.0) {
                overlayView.recordingTimerView.countDown = YES;
            }
            [imagePickerController startVideoCapture];
            recording = YES;
            recordedOrientation = imagePickerController.interfaceOrientation;
        }
        
        [self updateRecordingButtonForState];    
        [self updateCameraDeviceButtonForState];
    }
}

- (IBAction)onSelectCamera:(UIButton *)sender {
	if (imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
		imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
	} else {
		imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
	}
	
	[self updateCameraDeviceButtonForState];
	[self updateCameraModeButtonForState];
	[self updateRecordingButtonForState];
	[self updateFlashButtonForState];
}

- (IBAction)onSwitchMode:(BMDraggableButton *)sender {
    
    NSMutableArray *stateArray = [NSMutableArray array];
    
    [stateArray addObject:@(overlayView.cancelButton1.hidden)];
    [stateArray addObject:@(overlayView.cancelButton2.hidden)];
    [stateArray addObject:@(overlayView.flashLightButton1.hidden)];
    [stateArray addObject:@(overlayView.flashLightButton2.hidden)];
    [stateArray addObject:@(overlayView.cameraSelectionButton1.hidden)];
    [stateArray addObject:@(overlayView.cameraSelectionButton2.hidden)];
    [stateArray addObject:@(overlayView.recordButton.enabled)];
    [stateArray addObject:@(overlayView.switchModeButton.enabled)];
    [stateArray addObject:@(overlayView.lastImageButton.enabled)];
    [stateArray addObject:@(overlayView.photoIcon.enabled)];
    [stateArray addObject:@(overlayView.videoIcon.enabled)];
    
    if (sender.state == BMDraggableButtonStateMax) {
		imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
	} else {
		imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
	}
    
    [self updateCameraModeButtonForState];
	[self updateRecordingButtonForState];
    [self updateFlashButtonForState];
    
    overlayView.cameraSelectionButton1.hidden = YES;
    overlayView.cameraSelectionButton2.hidden = YES;
    overlayView.recordButton.enabled = NO;
    overlayView.switchModeButton.enabled = NO;
    overlayView.lastImageButton.enabled = NO;
    overlayView.photoIcon.enabled = NO;
    overlayView.videoIcon.enabled = NO;
    overlayView.flashLightButton1.hidden = YES;
    overlayView.flashLightButton2.hidden = YES;
    overlayView.cancelButton1.hidden = YES;
    overlayView.cancelButton2.hidden = YES;
	
    if (BMOSVersionIsAtLeast(@"7.0")) {
        [self performSelector:@selector(updateButtonsAfterModeSwitch:) withObject:stateArray afterDelay:0.5];
    } else {
        [self performSelector:@selector(updateButtonsAfterModeSwitch:) withObject:stateArray afterDelay:1.5];
    }
    
}

- (void)updateButtonsAfterModeSwitch:(NSArray *)stateArray {
    overlayView.cancelButton1.hidden = [stateArray[0] boolValue];
    overlayView.cancelButton2.hidden = [stateArray[1] boolValue];
    overlayView.flashLightButton1.hidden = [stateArray[2] boolValue];
    overlayView.flashLightButton2.hidden = [stateArray[3] boolValue];
    overlayView.cameraSelectionButton1.hidden = [stateArray[4] boolValue];
    overlayView.cameraSelectionButton2.hidden = [stateArray[5] boolValue];
    overlayView.recordButton.enabled = [stateArray[6] boolValue];
    overlayView.switchModeButton.enabled = [stateArray[7] boolValue];
    overlayView.lastImageButton.enabled = [stateArray[8] boolValue];  
    overlayView.photoIcon.enabled = [stateArray[9] boolValue];
    overlayView.videoIcon.enabled = [stateArray[10] boolValue];
}

- (IBAction)onFlashLight:(BMFlashButton *)sender {
    
    UIImagePickerControllerCameraFlashMode flashMode = [sender.selectedItem.value intValue];
	
	imagePickerController.cameraFlashMode = flashMode;
    
    [self updateFlashButtonForState];
}

- (IBAction)onToggleFlashLightExpansion:(BMFlashButton *)sender {
    BOOL hidden1 = ![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] || overlayView.flashLightButton1.isExpanded || recording;

    BOOL currentHidden1 = overlayView.cameraSelectionButton1.hidden;
    
    BOOL hidden2 = ![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] || overlayView.flashLightButton2.isExpanded || recording;
    
    BOOL currentHidden2 = overlayView.cameraSelectionButton2.hidden;
    
    BOOL animate1 = overlayView.cameraSelectionButton1.alpha != 0.0 && currentHidden1 != hidden1;
    BOOL animate2 = overlayView.cameraSelectionButton2.alpha != 0.0 && currentHidden2 != hidden2;
    
    if (currentHidden1 && animate1) {
        overlayView.cameraSelectionButton1.alpha = 0.0;
        overlayView.cameraSelectionButton1.hidden = NO;
    }
    
    if (currentHidden2 && animate2) {
        overlayView.cameraSelectionButton2.alpha = 0.0;
        overlayView.cameraSelectionButton2.hidden = NO;
    }
    
    [UIView animateWithDuration:BMFlashButtonExpandAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        if (animate1) {
            overlayView.cameraSelectionButton1.alpha = hidden1 ? 0.0 : 1.0;
        }
        
        if (animate2) {
            overlayView.cameraSelectionButton2.alpha = hidden2 ? 0.0 : 1.0;
        }
        
    } completion:^(BOOL finished) {
        
        if (animate1) {
            overlayView.cameraSelectionButton1.alpha = 1.0;
        }
        
        if (animate2) {
            overlayView.cameraSelectionButton2.alpha = 1.0;
        }
        [self updateCameraDeviceButtonForState];
    }];
}

- (IBAction)onSelectLastImage:(UIButton *)sender {
    [self lastMediaItemWasSelected];    
}

#pragma mark - 
#pragma mark Protected methods

- (void)lastMediaItemWasSelected {
    if ([self.delegate respondsToSelector:@selector(cameraController:didSelectMedia:)]) {
        id <BMMediaContainer> theMedia = [self.media lastObject];
        if (theMedia) {
            [(id <BMCameraControllerDelegate>)self.delegate cameraController:self didSelectMedia:theMedia];
        }
    }
}

#pragma mark -
#pragma mark BMOperationQueueDelegate implementation

- (void)operationQueue:(BMOperationQueue *)queue didFinishOperation:(NSOperation *)operation {
	[scheduledOperations removeObject:operation];
}

#pragma mark -
#pragma mark Notifications

@end

@implementation BMCameraController(Private)

- (void)updateFlashButtonForState {
    
    NSArray *items = nil;
    NSUInteger selectedIndex = 0;
    
    if (imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        if (imagePickerController.cameraCaptureMode == UIImagePickerControllerCameraCaptureModeVideo) {
            items = @[[BMEnumeratedValue enumeratedValueWithValue:@(UIImagePickerControllerCameraFlashModeOn) label:BMMediaLocalizedString(@"camera.button.flash.on", @"On")], [BMEnumeratedValue enumeratedValueWithValue:@(UIImagePickerControllerCameraFlashModeOff) label:BMMediaLocalizedString(@"camera.button.flash.off", @"Off")]];
            
            switch (imagePickerController.cameraFlashMode) {
                case UIImagePickerControllerCameraFlashModeAuto:
                case UIImagePickerControllerCameraFlashModeOff:
                    selectedIndex = 1;
                    break;
                case UIImagePickerControllerCameraFlashModeOn:
                    selectedIndex = 0;
                    break;
            }
        } else {
            items = @[[BMEnumeratedValue enumeratedValueWithValue:@(UIImagePickerControllerCameraFlashModeAuto) label:BMMediaLocalizedString(@"camera.button.flash.auto", @"Auto")],
                     [BMEnumeratedValue enumeratedValueWithValue:@(UIImagePickerControllerCameraFlashModeOn) label:BMMediaLocalizedString(@"camera.button.flash.on", @"On")], [BMEnumeratedValue enumeratedValueWithValue:@(UIImagePickerControllerCameraFlashModeOff) label:BMMediaLocalizedString(@"camera.button.flash.off", @"Off")]];
            
            switch (imagePickerController.cameraFlashMode) {
                case UIImagePickerControllerCameraFlashModeAuto:
                    selectedIndex = 0;
                    break;
                case UIImagePickerControllerCameraFlashModeOff:
                    selectedIndex = 2;
                    break;
                case UIImagePickerControllerCameraFlashModeOn:
                    selectedIndex = 1;
                    break;
            }
        }    
    }
    
    overlayView.flashLightButton1.hidden = (items == nil);
    overlayView.flashLightButton2.hidden = (items == nil);
    
    overlayView.flashLightButton1.selectedIndex = selectedIndex;
    overlayView.flashLightButton2.selectedIndex = selectedIndex;
    
    overlayView.flashLightButton1.items = items;
    overlayView.flashLightButton2.items = items;
}

- (void)updateCameraDeviceButtonForState {
	overlayView.cameraSelectionButton1.hidden = ![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] || overlayView.flashLightButton1.isExpanded || recording;
	overlayView.flashLightButton1.hidden = ![UIImagePickerController isFlashAvailableForCameraDevice:imagePickerController.cameraDevice];
	overlayView.cameraSelectionButton2.hidden = ![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] || overlayView.flashLightButton2.isExpanded || recording;
	overlayView.flashLightButton2.hidden = ![UIImagePickerController isFlashAvailableForCameraDevice:imagePickerController.cameraDevice];
	overlayView.switchModeButton.hidden = [UIImagePickerController availableCaptureModesForCameraDevice:imagePickerController.cameraDevice].count <= 1;
    overlayView.switchModeButton.enabled = !recording;
    overlayView.photoIcon.enabled = !recording;
    overlayView.videoIcon.enabled = !recording;
}


- (void)updateCameraModeButtonForState {
}


- (void)updateRecordingButtonForState {
    UIImage *image = nil;
    NSMutableArray *images = [NSMutableArray new];
	
	if (imagePickerController.cameraCaptureMode == UIImagePickerControllerCameraCaptureModeVideo) {
		if (recording) {
            if (!overlayView.recordingTimerView.isTiming) {
                [overlayView.recordingTimerView startTimer];
            }
            overlayView.recordingTimerView.hidden = NO;
            overlayView.orientationLocked = YES;
            
			image = [UIImage imageNamed:@"BMMedia.bundle/PLCameraButtonRecordOn.png"];
            
            [images addObject:image];
            
            image = [UIImage imageNamed:@"BMMedia.bundle/PLCameraButtonRecordOff.png"];
            
            [images addObject:image];
            
		} else {
            [overlayView.recordingTimerView stopTimer];
            overlayView.recordingTimerView.hidden = YES;
            overlayView.orientationLocked = NO;
            image = [UIImage imageNamed:@"BMMedia.bundle/PLCameraButtonRecordOff.png"];
		}
	} else {
        [overlayView.recordingTimerView stopTimer];
        overlayView.recordingTimerView.hidden = YES;
        overlayView.orientationLocked = NO;
        image = [UIImage imageNamed:@"BMMedia.bundle/PLCameraButtonIcon.png"];
	}
    
    if (images.count > 1) {
        [overlayView.recordButton setImage:images[0] forState:UIControlStateNormal];
        overlayView.recordButton.imageView.animationImages = images;
        overlayView.recordButton.imageView.animationDuration = 1.0;
        overlayView.recordButton.imageView.animationRepeatCount = 0;
        [overlayView.recordButton.imageView startAnimating];
    } else {
        [overlayView.recordButton.imageView stopAnimating];
        [overlayView.recordButton setImage:image forState:UIControlStateNormal];
    }
    
    overlayView.cancelButton1.hidden = recording;
    overlayView.cancelButton2.hidden = recording;
    
}

- (void)updateLastImageButtonWithImage:(UIImage *)theImage animated:(BOOL)animated {
	if (animated) {
		UIImageView *newImageView = [[UIImageView alloc] initWithImage:theImage];
		newImageView.frame = overlayView.lastImageButton.imageView.bounds;
		[overlayView.lastImageButton.imageView addSubview:newImageView];
		newImageView.alpha = 0.0;
		newImageView.contentMode = overlayView.lastImageButton.imageView.contentMode;
		newImageView.layer.cornerRadius = overlayView.lastImageButton.imageView.layer.cornerRadius;
		
        [UIView animateWithDuration:0.3 animations:^{
            newImageView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self animationDidStop:@"ButtonAnimation" finished:finished context:newImageView];
        }];
	} else {
		[overlayView.lastImageButton setImage:theImage forState:UIControlStateNormal];
	}
}

- (void)startAnimationWithImage:(UIImage *)theImage {
	
	CGFloat width = MIN(overlayView.frame.size.width, overlayView.frame.size.height);
	CGPoint center = CGPointMake(overlayView.frame.size.width/2, overlayView.frame.size.height/2);
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(center.x - width/2, center.y - width/2, 
																			width, width)];
	
	CGFloat imageWidth = MIN(theImage.size.width, theImage.size.height);
	
	imageView.image = [BMImageHelper cropImage:theImage toRect:CGRectMake((theImage.size.width - imageWidth)/2,(theImage.size.height - imageWidth)/2, imageWidth, imageWidth) withCornerRadius:(int)(imageWidth/10)];
	imageView.contentMode = overlayView.lastImageButton.imageView.contentMode;
    imageView.transform = overlayView.lastImageButton.imageView.transform;
	
	[overlayView addSubview:imageView];
	
    [UIView animateWithDuration:0.4 animations:^{
        CGRect theFrame = [overlayView.lastImageButton convertRect:overlayView.lastImageButton.bounds toView:overlayView];
        
        CGFloat factor = 0.7;
        theFrame = CGRectMake(CGRectGetMinX(theFrame) + (1 - factor) * CGRectGetWidth(theFrame)/2.0, CGRectGetMinY(theFrame) + (1 - factor) * CGRectGetHeight(theFrame)/2.0, CGRectGetWidth(theFrame) * factor, CGRectGetHeight(theFrame) * factor);
        imageView.frame = theFrame;
        
        overlayView.lastImageButton.imageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self animationDidStop:@"FlyAnimation" finished:finished context:imageView];
    }];
}

- (void)animationDidStop:(NSString *)animationID finished:(BOOL)finished context:(UIImageView *)imageView {
	if (imagePickerController) {
        if ([animationID isEqual:@"FlyAnimation"]) {
            [UIView animateWithDuration:0.1 animations:^{
                CGRect theFrame = [overlayView.lastImageButton convertRect:overlayView.lastImageButton.bounds toView:overlayView];
                imageView.frame = theFrame;
            } completion:^(BOOL finished) {
                [self animationDidStop:@"GrowAnimation" finished:finished context:imageView];
            }];
        } else if ([animationID isEqual:@"GrowAnimation"]) {
            overlayView.lastImageButton.imageView.alpha = 1.0;
            
            [self updateLastImageButtonWithImage:imageView.image animated:NO];
            [imageView removeFromSuperview];
        } else if ([animationID isEqual:@"ButtonAnimation"]) {
            [self updateLastImageButtonWithImage:imageView.image animated:NO];
            [imageView removeFromSuperview];
        }
    }
}

- (void)addPicture:(UIImage *)image withOrientation:(BMMediaOrientation)orientation andMetaData:(NSDictionary *)metaData {
    id <BMPictureContainer> pic = [self.delegate pictureContainerForMediaPickerController:self];
    
    pic.mediaOrientation = orientation;
    pic.metaData = metaData;
    [self addMedia:pic];
    
    UIImage *animationImage = [BMImageHelper scaleAndRotateImage:image maxResolution:[[pic class] maxThumbnailResolution]];
    BMPictureSaveOperation *operation = [[BMPictureSaveOperation alloc] initWithImage:image picture:pic];
    operation.sizesToSave = BMPictureSizeAll;
    operation.thumbnailImage = animationImage;
    operation.saveToCameraRoll = self.saveToCameraRoll;
	[self scheduleOperation:operation];
    
    [self startAnimationWithImage:animationImage];
}

- (void)addVideo:(NSURL *)mediaUrl withOrientation:(BMMediaOrientation)orientation andMetaData:(NSDictionary *)metaData {
    id <BMVideoContainer> vid = [self.delegate videoContainerForMediaPickerController:self];
    vid.mediaOrientation = orientation;
    vid.metaData = metaData;
	[self addMedia:vid];
	
    UIImage *theImage = [BMImageHelper thumbnailFromVideoAtURL:mediaUrl];
    
	BMVideoSaveOperation *operation = [[BMVideoSaveOperation alloc] initWithVideo:vid originalVideoPath:[mediaUrl path] image:theImage];
    operation.saveToCameraRoll = self.saveToCameraRoll;
	[self scheduleOperation:operation];
    
    [self startAnimationWithImage:theImage];
}

- (void)scheduleOperation:(BMMediaSaveOperation *)operation {
	BMOperationQueue *operationQueue = self.operationQueue;
	[scheduledOperations addObject:operation];
	[operationQueue scheduleOperation:operation];
}

- (UIImage *)stretchedImageNamed:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width/2) topCapHeight:(int)(image.size.height/2)];
    return image;
}

- (BMOperationQueue *)operationQueue {
    return [BMOperationQueue sharedInstance];
}

- (void)hideButtons {
    overlayView.cancelButton1.hidden = YES;
    overlayView.cancelButton2.hidden = YES;
    overlayView.flashLightButton1.hidden = YES;
    overlayView.flashLightButton2.hidden = YES;
    overlayView.cameraSelectionButton1.hidden = YES;
    overlayView.cameraSelectionButton2.hidden = YES;
    overlayView.recordingTimerView.hidden = YES;
}

- (void)showButtons {
    [self updateFlashButtonForState];
    [self updateRecordingButtonForState];
    [self updateCameraModeButtonForState];
    [self updateCameraDeviceButtonForState];
}

- (void)showButtonsConditionally {
    if (imagePickerController.viewState == BMViewStateVisible) {
        [self showButtons];
    }
}

@end

