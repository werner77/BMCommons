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

#import "Three20Style/BMTTStyleSheet.h"

// Style
#import "Three20Style/BMTTDefaultStyleSheet.h"

// Core
#import "Three20Core/BMTTCorePreprocessorMacros.h"

static BMTTStyleSheet* gStyleSheet = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMTTStyleSheet


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    [[NSNotificationCenter defaultCenter]
     addObserver: self
        selector: @selector(didReceiveMemoryWarning:)
            name: UIApplicationDidReceiveMemoryWarningNotification
          object: nil];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [[NSNotificationCenter defaultCenter]
   removeObserver: self
             name: UIApplicationDidReceiveMemoryWarningNotification
           object: nil];
  BMTT_RELEASE_SAFELY(_styles);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BMTTStyleSheet*)globalStyleSheet {
  if (!gStyleSheet) {
    gStyleSheet = [[BMTTDefaultStyleSheet alloc] init];
  }
  return gStyleSheet;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setGlobalStyleSheet:(BMTTStyleSheet*)styleSheet {
  [gStyleSheet release];
  gStyleSheet = [styleSheet retain];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSNotifications


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning:(void*)object {
  [self freeMemory];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)styleWithSelector:(NSString*)selector {
  return [self styleWithSelector:selector forState:UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)styleWithSelector:(NSString*)selector forState:(UIControlState)state {
  NSString* key = state == UIControlStateNormal
    ? selector
    : [NSString stringWithFormat:@"%@%tu", selector, state];
  BMTTStyle* style = [_styles objectForKey:key];
  if (!style) {
    SEL sel = NSSelectorFromString(selector);
    if ([self respondsToSelector:sel]) {
      style = [self performSelector:sel withObject:(id)state];
      if (style) {
        if (!_styles) {
          _styles = [[NSMutableDictionary alloc] init];
        }
        [_styles setObject:style forKey:key];
      }
    }
  }
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)freeMemory {
  BMTT_RELEASE_SAFELY(_styles);
}


@end
