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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * @return the current runtime version of the iPhone OS.
 */
float BMTTOSVersion();

/**
 * Checks if the link-time version of the OS is at least a certain version.
 */
BOOL BMTTOSVersionIsAtLeast(float version);

/**
 * @return TRUE if the keyboard is visible.
 */
BOOL BMTTIsKeyboardVisible();

/**
 * @return TRUE if the device has phone capabilities.
 */
BOOL BMTTIsPhoneSupported();

/**
 * @return TRUE if the device is iPad.
 */
BOOL BMTTIsPad();

/**
 * @return the current device orientation.
 */
UIDeviceOrientation BMTTDeviceOrientation();

/**
 * On iPhone/iPod touch
 * Checks if the orientation is portrait, landscape left, or landscape right.
 * This helps to ignore upside down and flat orientations.
 *
 * On iPad:
 * Always returns Yes.
 */
BOOL BMTTIsSupportedOrientation(UIInterfaceOrientation orientation);

/**
 * @return the rotation transform for a given orientation.
 */
CGAffineTransform BMTTRotateTransformForOrientation(UIInterfaceOrientation orientation);

/**
 * @return the application frame with no offset.
 *
 * From the Apple docs:
 * Frame of application screen area in points (i.e. entire screen minus status bar if visible)
 */
CGRect BMTTApplicationFrame();

/**
 * @return the toolbar height for a given orientation.
 *
 * The toolbar is slightly shorter in landscape.
 */
CGFloat BMTTToolbarHeightForOrientation(UIInterfaceOrientation orientation);

/**
 * @return the height of the keyboard for a given orientation.
 */
CGFloat BMTTKeyboardHeightForOrientation(UIInterfaceOrientation orientation);

/**
 * @return the space between the edge of the screen and a grouped table cell. Larger on iPad.
 */
CGFloat BMTTGroupedTableCellInset();

/**
 * A convenient way to show a UIAlertView with a message.
 */
void BMTTAlert(NSString* message);

/**
 * Same as BMTTAlert but the alert view has no title.
 */
void BMTTAlertNoTitle(NSString* message);


///////////////////////////////////////////////////////////////////////////////////////////////////
// Debug logging helpers

#define BMTTLOGRECT(rect) \
  BMTTDINFO(@"%s x=%f, y=%f, w=%f, h=%f", #rect, rect.origin.x, rect.origin.y, \
  rect.size.width, rect.size.height)

#define BMTTLOGPOINT(pt) \
  BMTTDINFO(@"%s x=%f, y=%f", #pt, pt.x, pt.y)

#define BMTTLOGSIZE(size) \
  BMTTDINFO(@"%s w=%f, h=%f", #size, size.width, size.height)

#define BMTTLOGEDGES(edges) \
  BMTTDINFO(@"%s left=%f, right=%f, top=%f, bottom=%f", #edges, edges.left, edges.right, \
  edges.top, edges.bottom)

#define BMTTLOGHSV(_COLOR) \
  BMTTDINFO(@"%s h=%f, s=%f, v=%f", #_COLOR, _COLOR.hue, _COLOR.saturation, _COLOR.value)

#define BMTTLOGVIEWS(_VIEW) \
  { for (UIView* view = _VIEW; view; view = view.superview) { BMTTDINFO(@"%@", view); } }


///////////////////////////////////////////////////////////////////////////////////////////////////
// Dimensions of common iPhone OS Views

/**
 * The standard height of a row in a table view controller.
 * @const 44 pixels
 */
extern const CGFloat ttkDefaultRowHeight;

/**
 * The standard height of a toolbar in portrait orientation.
 * @const 44 pixels
 */
extern const CGFloat ttkDefaultPortraitToolbarHeight;

/**
 * The standard height of a toolbar in landscape orientation.
 * @const 33 pixels
 */
extern const CGFloat ttkDefaultLandscapeToolbarHeight;

/**
 * The standard height of the keyboard in portrait orientation.
 * @const 216 pixels
 */
extern const CGFloat ttkDefaultPortraitKeyboardHeight;

/**
 * The standard height of the keyboard in landscape orientation.
 * @const 160 pixels
 */
extern const CGFloat ttkDefaultLandscapeKeyboardHeight;

/**
 * The space between the edge of the screen and the cell edge in grouped table views.
 * @const 10 pixels
 */
extern const CGFloat ttkGroupedTableCellInset;

/**
 * Deprecated macros for common constants.
 */
#define BMTT_ROW_HEIGHT                 ttkDefaultRowHeight
#define BMTT_TOOLBAR_HEIGHT             ttkDefaultPortraitToolbarHeight
#define BMTT_LANDSCAPE_TOOLBAR_HEIGHT   ttkDefaultLandscapeToolbarHeight

#define BMTT_KEYBOARD_HEIGHT                 ttkDefaultPortraitKeyboardHeight
#define BMTT_LANDSCAPE_KEYBOARD_HEIGHT       ttkDefaultLandscapeKeyboardHeight
#define BMTT_IPAD_KEYBOARD_HEIGHT            ttkDefaultPadPortraitKeyboardHeight
#define BMTT_IPAD_LANDSCAPE_KEYBOARD_HEIGHT  ttkDefaultPadLandscapeKeyboardHeight

///////////////////////////////////////////////////////////////////////////////////////////////////
// Animation

/**
 * The standard duration length for a transition.
 * @const 0.3 seconds
 */
extern const CGFloat ttkDefaultTransitionDuration;

/**
 * The standard duration length for a fast transition.
 * @const 0.2 seconds
 */
extern const CGFloat ttkDefaultFastTransitionDuration;

/**
 * The standard duration length for a flip transition.
 * @const 0.7 seconds
 */
extern const CGFloat ttkDefaultFlipTransitionDuration;

/**
 * Deprecated macros for common constants.
 */
#define BMTT_TRANSITION_DURATION      ttkDefaultTransitionDuration
#define BMTT_FAST_TRANSITION_DURATION ttkDefaultFastTransitionDuration
#define BMTT_FLIP_TRANSITION_DURATION ttkDefaultFlipTransitionDuration
