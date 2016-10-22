//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UICommon/BMTTBaseViewController.h"

// UICommon
#import "Three20UICommon/BMTTGlobalUICommon.h"
#import "Three20UICommon/UIViewControllerAdditions.h"
#import "Three20UICommon/UIViewControllerGarbageCollection.h"

// Core
#import "Three20Core/BMTTCorePreprocessorMacros.h"
#import "Three20Core/BMTTDebug.h"
#import "Three20Core/BMTTDebugFlags.h"

#import <BMCommons/BMUICore.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMTTBaseViewController

@synthesize navigationBarStyle      = _navigationBarStyle;
@synthesize navigationBarTintColor  = _navigationBarTintColor;
@synthesize navigationBarTextTintColor  = _navigationBarTextTintColor;
@synthesize statusBarStyle          = _statusBarStyle;
@synthesize isViewAppearing         = _isViewAppearing;
@synthesize hasViewAppeared         = _hasViewAppeared;
@synthesize autoresizesForKeyboard  = _autoresizesForKeyboard;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    _navigationBarStyle = UIBarStyleDefault;
    _statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithNibName:nil bundle:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BMTTDCONDITIONLOG(BMTTDFLAG_VIEWCONTROLLERS, @"DEALLOC %@", self);

  [self unsetCommonProperties];

  BMTT_RELEASE_SAFELY(_navigationBarTintColor);
  BMTT_RELEASE_SAFELY(_frozenState);

  // Removes keyboard notification observers for
  self.autoresizesForKeyboard = NO;

  // You would think UIViewController would call this in dealloc, but it doesn't!
  // I would prefer not to have to redundantly put all view releases in dealloc and
  // viewDidUnload, so my solution is just to call viewDidUnload here.
  if ([self isViewLoaded]) {
    [self viewDidUnload];
  }
  [super dealloc];
}

- (void)viewDidUnload {
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resizeForKeyboard:(NSNotification*)notification appearing:(BOOL)appearing {
	CGRect keyboardFrameStart;
    CGRect keyboardFrameEnd;

	[[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]
     getValue:&keyboardFrameStart];
    [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]
     getValue:&keyboardFrameEnd];
    CGPoint keyboardStart = CGPointMake(keyboardFrameStart.origin.x +
                                        keyboardFrameStart.size.width,
                                        keyboardFrameStart.origin.y +
                                        keyboardFrameStart.size.height);
	CGPoint keyboardEnd = CGPointMake(keyboardFrameEnd.origin.x + keyboardFrameEnd.size.width,
                                      keyboardFrameEnd.origin.y + keyboardFrameEnd.size.height);
    CGRect keyboardBounds = CGRectMake(0, 0,
                                       keyboardFrameEnd.size.width, keyboardFrameEnd.size.height);

	BOOL animated = keyboardStart.y != keyboardEnd.y;
  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:BMTT_TRANSITION_DURATION];
  }

  if (appearing) {
    [self keyboardWillAppear:animated withBounds:keyboardBounds];

  } else {
    [self keyboardDidDisappear:animated withBounds:keyboardBounds];
  }

  if (animated) {
    [UIView commitAnimations];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController (BMTTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)frozenState {
  return _frozenState;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFrozenState:(NSDictionary*)frozenState {
  [_frozenState release];
  _frozenState = [frozenState retain];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  _isViewAppearing = YES;
  _hasViewAppeared = YES;

  if (!self.popupViewController) {
    UINavigationBar* bar = self.navigationController.navigationBar;
    bar.barTintColor = _navigationBarTintColor;
    bar.tintColor = _navigationBarTextTintColor;
    bar.barStyle = _navigationBarStyle;

    if (!BMTTIsPad()) {
      [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle animated:YES];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  _isViewAppearing = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
  BMTTDCONDITIONLOG(BMTTDFLAG_VIEWCONTROLLERS, @"MEMORY WARNING FOR %@", self);

  if (_hasViewAppeared && !_isViewAppearing) {
    NSMutableDictionary* state = [[NSMutableDictionary alloc] init];
    [self persistView:state];
    self.frozenState = state;
    BMTT_RELEASE_SAFELY(state);

    // This will come around to calling viewDidUnload
    [super didReceiveMemoryWarning];

    _hasViewAppeared = NO;

  } else {
    [super didReceiveMemoryWarning];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if (BMTTIsPad()) {
    return YES;

  } else {
    UIViewController* popup = [self popupViewController];
    if (popup) {
      return [popup shouldAutorotateToInterfaceOrientation:interfaceOrientation];

    } else {
      return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
  UIViewController* popup = [self popupViewController];

  if (popup) {
    return [popup willAnimateRotationToInterfaceOrientation: fromInterfaceOrientation
                                                   duration: duration];

  } else {
    return [super willAnimateRotationToInterfaceOrientation: fromInterfaceOrientation
                                                   duration: duration];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  UIViewController* popup = [self popupViewController];

  if (popup) {
    return [popup didRotateFromInterfaceOrientation:fromInterfaceOrientation];

  } else {
    return [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)rotatingHeaderView {
  UIViewController* popup = [self popupViewController];

  if (popup) {
    return [popup rotatingHeaderView];

  } else {
    return [super rotatingHeaderView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)rotatingFooterView {
  UIViewController* popup = [self popupViewController];

  if (popup) {
    return [popup rotatingFooterView];

  } else {
    return [super rotatingFooterView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIKeyboardNotifications


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardWillShow:(NSNotification*)notification {
  if (self.isViewAppearing) {
    [self resizeForKeyboard:notification appearing:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardDidShow:(NSNotification*)notification {
  CGRect frameStart;
  [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&frameStart];

  CGRect keyboardBounds = CGRectMake(0, 0, frameStart.size.width, frameStart.size.height);

  [self keyboardDidAppear:YES withBounds:keyboardBounds];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardDidHide:(NSNotification*)notification {
  if (self.isViewAppearing) {
    [self resizeForKeyboard:notification appearing:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardWillHide:(NSNotification*)notification {
  CGRect frameEnd;
  [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&frameEnd];

  CGRect keyboardBounds = CGRectMake(0, 0, frameEnd.size.width, frameEnd.size.height);

  [self keyboardWillDisappear:YES withBounds:keyboardBounds];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setAutoresizesForKeyboard:(BOOL)autoresizesForKeyboard {
  if (autoresizesForKeyboard != _autoresizesForKeyboard) {
    _autoresizesForKeyboard = autoresizesForKeyboard;

    if (_autoresizesForKeyboard) {
      [[NSNotificationCenter defaultCenter] addObserver: self
                                               selector: @selector(keyboardWillShow:)
                                                   name: UIKeyboardWillShowNotification
                                                 object: nil];
      [[NSNotificationCenter defaultCenter] addObserver: self
                                               selector: @selector(keyboardWillHide:)
                                                   name: UIKeyboardWillHideNotification
                                                 object: nil];
      [[NSNotificationCenter defaultCenter] addObserver: self
                                               selector: @selector(keyboardDidShow:)
                                                   name: UIKeyboardDidShowNotification
                                                 object: nil];
      [[NSNotificationCenter defaultCenter] addObserver: self
                                               selector: @selector(keyboardDidHide:)
                                                   name: UIKeyboardDidHideNotification
                                                 object: nil];

    } else {
      [[NSNotificationCenter defaultCenter] removeObserver: self
                                                      name: UIKeyboardWillShowNotification
                                                    object: nil];
      [[NSNotificationCenter defaultCenter] removeObserver: self
                                                      name: UIKeyboardWillHideNotification
                                                    object: nil];
      [[NSNotificationCenter defaultCenter] removeObserver: self
                                                      name: UIKeyboardDidShowNotification
                                                    object: nil];
      [[NSNotificationCenter defaultCenter] removeObserver: self
                                                      name: UIKeyboardDidHideNotification
                                                    object: nil];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardWillAppear:(BOOL)animated withBounds:(CGRect)bounds {
  // Empty default implementation.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardWillDisappear:(BOOL)animated withBounds:(CGRect)bounds {
  // Empty default implementation.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardDidAppear:(BOOL)animated withBounds:(CGRect)bounds {
  // Empty default implementation.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)keyboardDidDisappear:(BOOL)animated withBounds:(CGRect)bounds {
  // Empty default implementation.
}


@end
