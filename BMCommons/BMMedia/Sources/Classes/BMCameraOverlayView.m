//
//  BMCameraOverlayView.m
//  BMCommons
//
//  Created by Werner Altewischer on 21/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCameraOverlayView.h>
#import <QuartzCore/QuartzCore.h>
#import <BMMedia/BMMedia.h>
#import <CoreImage/CoreImage.h>
#import <BMUICore/UIView+BMCommons.h>

@implementation BMCameraOverlayView {
    IBOutlet UIView *toolbarContainerView;
	IBOutlet BMFlashButton *flashLightButton1;
	IBOutlet UIButton *cameraSelectionButton1;
	IBOutlet UIButton *cancelButton1;
	IBOutlet BMFlashButton *flashLightButton2;
	IBOutlet UIButton *cameraSelectionButton2;
	IBOutlet UIButton *cancelButton2;
	IBOutlet UIButton *recordButton;
	IBOutlet BMDraggableButton *switchModeButton;
	IBOutlet UIButton *lastImageButton;
	IBOutlet UIImageView *toolbar;
    IBOutlet UIButton *photoIcon;
    IBOutlet UIButton *videoIcon;
    IBOutlet BMRecordingTimerView *recordingTimerView;
    IBOutlet UIView *irisContainerView;
	int activeButtonSet;
	UIDeviceOrientation currentOrientation;
}

#define BUTTON_X_MARGIN 10.0f
#define BUTTON_Y_MARGIN 6.0f

#define CANCEL_BUTTON_OFFSET 3.0

@synthesize flashLightButton1, cameraSelectionButton1, cancelButton1, recordButton, switchModeButton, lastImageButton, toolbar;
@synthesize flashLightButton2, cameraSelectionButton2, cancelButton2, photoIcon, videoIcon, orientationLocked, irisContainerView;
@synthesize recordingTimerView, toolbarContainerView;

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
	currentOrientation = UIDeviceOrientationUnknown;
	
	lastImageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
	lastImageButton.imageView.layer.cornerRadius = 4.0;
    
    recordButton.imageView.contentMode = UIViewContentModeCenter;
    
    recordButton.adjustsImageWhenHighlighted = NO;
    recordButton.imageView.autoresizingMask = UIViewAutoresizingNone;
    recordButton.imageView.clipsToBounds = NO;
    
    UIImage *buttonImage = [UIImage imageNamed:@"BMMedia.bundle/PLCameraButton.png"];
    NSString *doneTitle = BMMediaLocalizedString(@"camera.button.done", @"Done");
    
    [cancelButton1 setTitle:doneTitle forState:UIControlStateNormal];
    [cancelButton2 setTitle:doneTitle forState:UIControlStateNormal];
    
    CGSize textSize = [cancelButton1.titleLabel sizeThatFits:CGSizeMake(self.bounds.size.width, buttonImage.size.height)];
    
    CGRect bounds = CGRectMake(0, 0, textSize.width + 25, buttonImage.size.height - 1);
    
    [cancelButton1 setBackgroundImage:[buttonImage stretchableImageWithLeftCapWidth:(int)(buttonImage.size.width/2) topCapHeight:(int)(buttonImage.size.height/2)] forState:UIControlStateNormal];
    [cancelButton2 setBackgroundImage:[buttonImage stretchableImageWithLeftCapWidth:(int)(buttonImage.size.width/2) topCapHeight:(int)(buttonImage.size.height/2)] forState:UIControlStateNormal];
    
    cancelButton1.bounds = bounds;
    cancelButton2.bounds = bounds;
    
    switchModeButton.slidingRange = CGRectMake(246 + switchModeButton.frame.size.width/2, switchModeButton.center.y, 284 - 246, 0);
	
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	if (orientation == UIDeviceOrientationFaceUp ||
		orientation == UIDeviceOrientationFaceDown ||
		orientation == UIDeviceOrientationUnknown) {
		orientation = UIDeviceOrientationPortrait;
	}
	[self adjustViewForOrientation:orientation animated:NO];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationChanged:)
												 name:UIDeviceOrientationDidChangeNotification
											   object:nil];
}

- (void)deviceOrientationChanged:(NSNotification *)notification {
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	//Reposition the buttons
    if (!self.orientationLocked) {
        [self adjustViewForOrientation:orientation animated:YES];
    }
}

- (void)adjustViewForOrientation:(UIDeviceOrientation)orientation animated:(BOOL)animated {
	
	if (orientation == currentOrientation) {
		return;
	}
	
	CGPoint flashLightButtonCenter, cameraSelectionButtonCenter, cancelButtonCenter, recordingTimerViewCenter;
	
	CGFloat angle = 0.0f;
	switch (orientation) {
		case UIDeviceOrientationPortraitUpsideDown:
			angle = M_PI;
		case UIDeviceOrientationPortrait:
			flashLightButtonCenter = CGPointMake(BUTTON_X_MARGIN + flashLightButton1.bounds.size.width/2, BUTTON_Y_MARGIN + flashLightButton1.bounds.size.height/2);
			cameraSelectionButtonCenter = CGPointMake(self.frame.size.width/2, BUTTON_Y_MARGIN + cameraSelectionButton1.bounds.size.height/2);
			cancelButtonCenter = CGPointMake(self.frame.size.width - BUTTON_X_MARGIN - cancelButton1.bounds.size.width/2, BUTTON_Y_MARGIN + cancelButton1.bounds.size.height/2 + CANCEL_BUTTON_OFFSET);
            recordingTimerViewCenter = CGPointMake(self.frame.size.width - BUTTON_X_MARGIN - recordingTimerView.bounds.size.width/2, BUTTON_Y_MARGIN + recordingTimerView.bounds.size.height/2); 
			break;
		case UIDeviceOrientationLandscapeLeft:
			angle = M_PI/2;
			flashLightButtonCenter = CGPointMake(self.frame.size.width - BUTTON_Y_MARGIN - flashLightButton2.bounds.size.height/2, BUTTON_X_MARGIN + flashLightButton2.bounds.size.width/2);
			cameraSelectionButtonCenter = CGPointMake(self.frame.size.width - BUTTON_Y_MARGIN - cameraSelectionButton1.bounds.size.height/2, self.frame.size.height/2 - toolbar.frame.size.height/2);
			cancelButtonCenter = CGPointMake(self.frame.size.width - BUTTON_Y_MARGIN - cancelButton1.bounds.size.height/2 - CANCEL_BUTTON_OFFSET, self.frame.size.height - toolbar.frame.size.height - BUTTON_X_MARGIN - cancelButton1.bounds.size.width/2);
            recordingTimerViewCenter = CGPointMake(self.frame.size.width - BUTTON_Y_MARGIN - recordingTimerView.bounds.size.height/2, self.frame.size.height - toolbar.frame.size.height - BUTTON_X_MARGIN - recordingTimerView.bounds.size.width/2);
			break;
		case UIDeviceOrientationLandscapeRight:
			angle = -M_PI/2;
			cancelButtonCenter = CGPointMake(BUTTON_Y_MARGIN + cancelButton1.bounds.size.height/2 + CANCEL_BUTTON_OFFSET, BUTTON_X_MARGIN + cancelButton1.bounds.size.width/2);
			cameraSelectionButtonCenter = CGPointMake(BUTTON_Y_MARGIN + cameraSelectionButton1.bounds.size.height/2, self.frame.size.height/2 - toolbar.frame.size.height/2);
			flashLightButtonCenter = CGPointMake(BUTTON_Y_MARGIN + flashLightButton2.bounds.size.height/2, self.frame.size.height - toolbar.frame.size.height - BUTTON_X_MARGIN - flashLightButton2.bounds.size.width/2);
            recordingTimerViewCenter = CGPointMake(BUTTON_Y_MARGIN + recordingTimerView.bounds.size.height/2, BUTTON_X_MARGIN + recordingTimerView.bounds.size.width/2);
			break;
		default:
			//Unsupported orientation, do nothing
			return;
	}
	
	currentOrientation = orientation;
    
    flashLightButtonCenter = CGPointMake((int)flashLightButtonCenter.x, (int)flashLightButtonCenter.y);
    cameraSelectionButtonCenter = CGPointMake((int)cameraSelectionButtonCenter.x, (int)cameraSelectionButtonCenter.y);
    cancelButtonCenter = CGPointMake((int)cancelButtonCenter.x, (int)cancelButtonCenter.y);
    recordingTimerViewCenter = CGPointMake((int)recordingTimerViewCenter.x, (int)recordingTimerViewCenter.y);
	
	CGAffineTransform theTransform = CGAffineTransformMakeRotation(angle);
	
	if (activeButtonSet == 1) {
		cancelButton2.center = cancelButtonCenter;
		cameraSelectionButton2.center = cameraSelectionButtonCenter;
		flashLightButton2.center = flashLightButtonCenter;
		
		flashLightButton2.transform = theTransform;
		cameraSelectionButton2.transform = theTransform;
		cancelButton2.transform = theTransform;
		
	} else {
		cancelButton1.center = cancelButtonCenter;
		cameraSelectionButton1.center = cameraSelectionButtonCenter;
		flashLightButton1.center = flashLightButtonCenter;
		
		flashLightButton1.transform = theTransform;
		cameraSelectionButton1.transform = theTransform;
		cancelButton1.transform = theTransform;
	}
    
    recordingTimerView.center = recordingTimerViewCenter;
    recordingTimerView.transform = theTransform;
	
	if (animated) {
		[UIView beginAnimations:@"AdjustView" context:nil];
		[UIView setAnimationDuration:0.5];
	}
	
	if (activeButtonSet == 1) {
		
		flashLightButton1.alpha = 0.0;
		cameraSelectionButton1.alpha = 0.0;
		cancelButton1.alpha = 0.0;
		
		flashLightButton2.alpha = 1.0;
		cameraSelectionButton2.alpha = 1.0;
		cancelButton2.alpha = 1.0;
		
		activeButtonSet = 2;
	} else {
		flashLightButton2.alpha = 0.0;
		cameraSelectionButton2.alpha = 0.0;
		cancelButton2.alpha = 0.0;
		
		flashLightButton1.alpha = 1.0;
		cameraSelectionButton1.alpha = 1.0;
		cancelButton1.alpha = 1.0;
		
		activeButtonSet = 1;
	}
	
	lastImageButton.imageView.transform = theTransform;
    recordButton.imageView.transform = theTransform;
    photoIcon.transform = theTransform;
    videoIcon.transform = theTransform;
    
    if (animated) {
		[UIView commitAnimations];
	}
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = self.superview.bounds;
}

- (void)animateIris {
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.type = @"cameraIris";
    
    UIView *v = irisContainerView ? irisContainerView : self;
    [v.layer addAnimation:animation forKey:nil];
}

- (CGRect)visibleArea {
    return CGRectMake(0, 0, self.bounds.size.width, CGRectGetMinY(self.toolbarContainerView.frame));
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

@end
