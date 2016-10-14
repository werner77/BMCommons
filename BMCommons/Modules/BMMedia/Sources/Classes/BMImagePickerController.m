//
//  BMImagePickerController.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/26/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMImagePickerController.h>
#import <BMCommons/BMUICore.h>
#import <QuartzCore/QuartzCore.h>

@interface BMImagePickerController ()

@end

@implementation BMImagePickerController {
    BMViewState _viewState;
    NSMutableDictionary *_scaleDictionary;
}

@synthesize viewState = _viewState;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        _scaleDictionary = [NSMutableDictionary new];
    }
    return self;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _viewState = BMViewStateToBecomeInvisible;
    if ([self.delegate respondsToSelector:@selector(imagePickerControllerWillDisappear:)]) {
        [(id <BMImagePickerControllerDelegate>)self.delegate imagePickerControllerWillDisappear:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _viewState = BMViewStateToBecomeVisible;
    if ([self.delegate respondsToSelector:@selector(imagePickerControllerWillAppear:)]) {
        [(id <BMImagePickerControllerDelegate>)self.delegate imagePickerControllerWillAppear:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _viewState = BMViewStateInvisible;
    if ([self.delegate respondsToSelector:@selector(imagePickerControllerDidDisappear:)]) {
        [(id <BMImagePickerControllerDelegate>)self.delegate imagePickerControllerDidDisappear:self];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewState = BMViewStateVisible;
    if ([self.delegate respondsToSelector:@selector(imagePickerControllerDidAppear:)]) {
        [(id <BMImagePickerControllerDelegate>)self.delegate imagePickerControllerDidAppear:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef __IPHONE_7_0
    if (BMOSVersionIsAtLeast(@"7.0")) {
        BM_START_IGNORE_TOO_NEW
        self.edgesForExtendedLayout = UIRectEdgeNone;
        BM_END_IGNORE_TOO_NEW
    }
#endif
    
    [self adjustViewForCaptureMode];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

- (void)setCameraCaptureMode:(UIImagePickerControllerCameraCaptureMode)cameraCaptureMode {
    [super setCameraCaptureMode:cameraCaptureMode];
    [self adjustViewForCaptureMode];
}

- (void)adjustViewForCaptureMode {
    CGFloat ratio = [self scaleFactorForCameraCaptureMode:self.cameraCaptureMode];
    self.cameraViewTransform = CGAffineTransformMakeScale(ratio, ratio);
}

- (CGFloat)scaleFactorForCameraCaptureMode:(UIImagePickerControllerCameraCaptureMode)cameraCaptureMode {
    NSNumber *n = _scaleDictionary[[NSNumber numberWithInt:(int)cameraCaptureMode]];
    CGFloat ret = 1.0f;
    if (n) {
        ret = [n floatValue];
    }
    return ret;
}

- (void)setScaleFactor:(CGFloat)scaleFactor forCameraCaptureMode:(UIImagePickerControllerCameraCaptureMode)cameraCaptureMode {
    _scaleDictionary[[NSNumber numberWithInt:(int)cameraCaptureMode]] = @(scaleFactor);
}

@end
