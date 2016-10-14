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

// Style
#import <BMCommons/Three20Style/BMTTStyleDelegate.h>

@class BMTTStyle;
@class BMTTLayout;

/**
 * A UIView with an attached style and layout that are used to render and
 * layout the view, respectively. Style and layout are optional.
 */
@interface BMTTView : UIView <BMTTStyleDelegate> {
  BMTTStyle*  _style;
  BMTTLayout* _layout;
}

@property (nonatomic, retain) BMTTStyle*  style;
@property (nonatomic, retain) BMTTLayout* layout;

- (void)drawContent:(CGRect)rect;

@end
