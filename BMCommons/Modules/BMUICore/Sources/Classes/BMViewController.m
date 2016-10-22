//
//  BMViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 28/09/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMViewController.h>
#import "UIView+BMCommons.h"
#import "UIViewController+BMCommons.h"
#import <BMCommons/BMUICore.h>

@interface BMViewController()<BMLocalizable>

@end

@interface BMViewController(Private)

- (void)unloadView;
- (SEL)popupViewControllerSelector;
- (void)initOnViewDidLoad;
- (void)cleanupOnViewDidUnload;

@end

@implementation BMViewController {
	BMViewState _viewState;
	BOOL _firstAppearAfterLoad;
	BOOL _firstLoad;
	BMViewFactory *_viewFactory;
	CGSize _contentSizeForViewInPopover;
    BMStyleSheet *_styleSheet;
    BOOL _styleSheetPushed;
    SEL _popupViewControllerSelector;
    BOOL _initializedAfterViewLoad;
}

@synthesize viewState = _viewState, firstAppearAfterLoad = _firstAppearAfterLoad, firstLoad = _firstLoad, viewFactory = _viewFactory, styleSheet = _styleSheet;

NSString *const BMViewControllerWillAppearNotification = @"BMViewControllerWillAppearNotification";
NSString *const BMViewControllerDidAppearNotification = @"BMViewControllerDidAppearNotification";
NSString *const BMViewControllerWillDisappearNotification = @"BMViewControllerWillDisappearNotification";
NSString *const BMViewControllerDidDisappearNotification = @"BMViewControllerDidDisappearNotification";

+ (void)sendNotification:(NSString *)notificationName forViewController:(UIViewController *)vc {
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:vc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {

        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    //Call localize here to be sure that the title is set, even if view has not been loaded yet
    _viewFactory = [[[self viewFactoryClass] alloc] initWithBundle:nil];
    [self localize];
    _firstLoad = YES;
    self.useFullScreenLayout = NO;
}

- (void)dismissWithResult:(id)result {
    if (self.dismissBlock) {
        self.dismissBlock(self, result);
    }
}

- (Class)viewFactoryClass {
    return [BMViewFactory class];
}

- (void)dealloc {
    if (self.isViewLoaded) {
        [self unloadView];
    }
    
    //This is to safe-guard against overriders of viewDidUnload that don't call super
    [self cleanupOnViewDidUnload];
    
    if (_styleSheetPushed) {
        [BMStyleSheet popStyleSheet];
    }
    LogDebug(@"dealloc: %@", self);
    BM_RELEASE_SAFELY(_viewFactory);
    BM_RELEASE_SAFELY(_styleSheet);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    if (self.styleSheet && !_styleSheetPushed) {
        [BMStyleSheet pushStyleSheet:self.styleSheet];
        _styleSheetPushed = YES;
    }
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    LogDebug(@"viewDidLoad: %@", self);
    _firstAppearAfterLoad = YES;
    
    [self initOnViewDidLoad];
}

- (void)viewWillUnload {
    LogDebug(@"viewWillUnload: %@", self);
}

- (void)viewDidUnload {
    _firstLoad = NO;
    LogDebug(@"viewDidUnload: %@", self);
    
    [self cleanupOnViewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    if (_viewState == BMViewStateInvisible || _viewState == BMViewStateToBecomeInvisible) {
        [super viewWillAppear:animated];

        _viewState = BMViewStateToBecomeVisible;
        
        if (_firstAppearAfterLoad) {
            [self localize];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
        
        LogDebug(@"viewWillAppear: %@", self);
        [[self class] sendNotification:BMViewControllerWillAppearNotification forViewController:self];

    } else {
        LogWarn(@"viewWillAppear was called with an invalid view state of: %d for viewController: %@", _viewState, self);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (_viewState == BMViewStateToBecomeVisible) {
        [super viewDidAppear:animated];
        
        _viewState = BMViewStateVisible;
        _firstAppearAfterLoad = NO;
        _firstLoad = NO;
        
        LogDebug(@"viewDidAppear: %@", self);
        [[self class] sendNotification:BMViewControllerDidAppearNotification forViewController:self];

    } else {
        LogWarn(@"viewDidAppear was called with an invalid view state of: %d for viewController: %@", _viewState, self);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (_viewState == BMViewStateVisible || _viewState == BMViewStateToBecomeVisible) {
        [super viewWillDisappear:animated];
        
        _viewState = BMViewStateToBecomeInvisible;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];

        LogDebug(@"viewWillDisappear: %@", self);
        [[self class] sendNotification:BMViewControllerWillDisappearNotification forViewController:self];
        
        
    } else {
        LogWarn(@"viewWillDissappear was called with an invalid view state of: %d for viewController: %@", _viewState, self);
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if (_viewState == BMViewStateToBecomeInvisible) {
        [super viewDidDisappear:animated];
        
        LogDebug(@"viewDidDisappear: %@", self);

        _viewState = BMViewStateInvisible;
        
        [[self class] sendNotification:BMViewControllerDidDisappearNotification forViewController:self];

    } else {
        LogWarn(@"viewDidDissappear was called with an invalid view state of: %d for viewController: %@", _viewState, self);
    }
}

- (void)didReceiveMemoryWarning {
    if (self.shouldUnloadViewAtMemoryWarning && BMOSVersionIsAtLeast(@"6.0")) {
        if ([self isViewLoaded] && !self.view.window) {
            [self unloadView];
        }
    }
    [super didReceiveMemoryWarning];
}

- (void)setUseFullScreenLayout:(BOOL)useFullScreenLayout {
    _useFullScreenLayout = useFullScreenLayout;
    if (useFullScreenLayout) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
    } else {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (BOOL)isViewVisible {
    return self.viewState == BMViewStateVisible;
}

#pragma mark -
#pragma mark Localizable implementation

- (void)localize {

}

#pragma mark -
#pragma mark Methods needed for backwards compatibility (iOS 3.1)

- (void)setContentSizeForViewInPopover:(CGSize)theSize {
    _contentSizeForViewInPopover = theSize;
}

- (CGSize)contentSizeForViewInPopover {
    return _contentSizeForViewInPopover;
}

#pragma mark -
#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification {
}

- (void)keyboardDidShow:(NSNotification *)notification {
}

- (void)keyboardWillHide:(NSNotification *)notification {
}

- (void)keyboardDidHide:(NSNotification *)notification {
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification {
}

#pragma mark - 
#pragma mark Autorotation

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return (UIInterfaceOrientationPortrait == toInterfaceOrientation);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    UIViewController* popup = nil;
    
    if ([self respondsToSelector:self.popupViewControllerSelector]) {
        popup = [self performSelector:self.popupViewControllerSelector];
    }
    
    if (popup) {
        [popup willAnimateRotationToInterfaceOrientation: fromInterfaceOrientation
                                                       duration: duration];
        
    }
    [super willAnimateRotationToInterfaceOrientation:fromInterfaceOrientation duration:duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    UIViewController* popup = nil;
    if ([self respondsToSelector:self.popupViewControllerSelector]) {
        popup = [self performSelector:self.popupViewControllerSelector];
    }
    
    if (popup) {
        [popup didRotateFromInterfaceOrientation:fromInterfaceOrientation];
        
    }
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


@end

@implementation BMViewController (Private)

- (void)unloadView {
    [self viewWillUnload];
    self.view = nil;
    [self viewDidUnload];
}

- (SEL)popupViewControllerSelector {
    if (!_popupViewControllerSelector) {
        _popupViewControllerSelector = NSSelectorFromString(@"popupViewController");
    }
    return _popupViewControllerSelector;
}

- (void)initOnViewDidLoad {
    if (!_initializedAfterViewLoad) {
        _initializedAfterViewLoad = YES;
        [[BMLocalization sharedInstance] registerLocalizable:self];
    }
}

- (void)cleanupOnViewDidUnload {
    if (_initializedAfterViewLoad) {
        [[BMLocalization sharedInstance] deregisterLocalizable:self];
        _initializedAfterViewLoad = NO;
    }
}

@end

