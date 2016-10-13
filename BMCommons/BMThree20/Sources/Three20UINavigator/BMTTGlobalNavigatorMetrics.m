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

#import "Three20UINavigator/BMTTGlobalNavigatorMetrics.h"

// UICommon
#import "Three20UICommon/BMTTGlobalUICommon.h"

#import <BMUICore/UIScreen+BMCommons.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
UIInterfaceOrientation BMTTInterfaceOrientation() {
  UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
  return orient;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect BMTTScreenBounds() {
  CGRect bounds = [UIScreen mainScreen].bmPortraitBounds;
  if (UIInterfaceOrientationIsLandscape(BMTTInterfaceOrientation())) {
    CGFloat width = bounds.size.width;
    bounds.size.width = bounds.size.height;
    bounds.size.height = width;
  }
  return bounds;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect BMTTNavigationFrame() {
  CGRect frame = [UIScreen mainScreen].bmPortraitApplicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height - BMTTToolbarHeight());
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect BMTTToolbarNavigationFrame() {
  CGRect frame = [UIScreen mainScreen].bmPortraitApplicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height - BMTTToolbarHeight()*2);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat BMTTStatusHeight() {
  UIInterfaceOrientation orientation = BMTTInterfaceOrientation();
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    return [UIScreen mainScreen].bmPortraitApplicationFrame.origin.x;

  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return -[UIScreen mainScreen].bmPortraitApplicationFrame.origin.x;

  } else {
    return [UIScreen mainScreen].bmPortraitApplicationFrame.origin.y;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat BMTTBarsHeight() {
  CGRect frame = [UIApplication sharedApplication].statusBarFrame;
  if (UIInterfaceOrientationIsPortrait(BMTTInterfaceOrientation())) {
    return frame.size.height + BMTT_ROW_HEIGHT;

  } else {
    return frame.size.width + BMTT_LANDSCAPE_TOOLBAR_HEIGHT;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat BMTTToolbarHeight() {
  return BMTTToolbarHeightForOrientation(BMTTInterfaceOrientation());
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat BMTTKeyboardHeight() {
  return BMTTKeyboardHeightForOrientation(BMTTInterfaceOrientation());
}
