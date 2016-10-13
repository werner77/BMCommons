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

typedef NS_ENUM(NSUInteger, BMTTActivityLabelStyle) {
  BMTTActivityLabelStyleWhite,
  BMTTActivityLabelStyleGray,
  BMTTActivityLabelStyleBlackBox,
  BMTTActivityLabelStyleBlackBezel,
  BMTTActivityLabelStyleBlackBanner,
  BMTTActivityLabelStyleWhiteBezel,
  BMTTActivityLabelStyleWhiteBox
};

@class BMTTView;

@interface BMTTActivityLabel : UIView {
  BMTTActivityLabelStyle      _style;

  BMTTView*                   _bezelView;
  UIProgressView*           _progressView;
  UIActivityIndicatorView*  _activityIndicator;
  UILabel*                  _label;

  float                     _progress;
  BOOL                      _smoothesProgress;
  NSTimer*                  _smoothTimer;
}

@property (nonatomic, readonly) BMTTActivityLabelStyle style;

@property (nonatomic, copy)     NSString* text;
@property (nonatomic, retain)   UIFont*   font;

@property (nonatomic)           float     progress;
@property (nonatomic)           BOOL      isAnimating;
@property (nonatomic)           BOOL      smoothesProgress;

- (id)initWithFrame:(CGRect)frame style:(BMTTActivityLabelStyle)style;
- (id)initWithFrame:(CGRect)frame style:(BMTTActivityLabelStyle)style text:(NSString*)text;
- (id)initWithStyle:(BMTTActivityLabelStyle)style;

@end
