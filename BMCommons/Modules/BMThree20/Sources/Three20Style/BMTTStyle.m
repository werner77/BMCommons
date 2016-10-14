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

#import "Three20Style/BMTTStyle.h"

// Style
#import "Three20Style/BMTTPartStyle.h"

// Core
#import "Three20Core/BMTTCorePreprocessorMacros.h"


#define ZEROLIMIT(_VALUE) (_VALUE < 0 ? 0 : (_VALUE > 1 ? 1 : _VALUE))


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMTTStyle

@synthesize next = _next;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(BMTTStyle*)next {
  if (self = [super init]) {
    _next = [next retain];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithNext:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BMTT_RELEASE_SAFELY(_next);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)next:(BMTTStyle*)next {
  self.next = next;
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(BMTTStyleContext*)context {
  [self.next draw:context];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)addToInsets:(UIEdgeInsets)insets forSize:(CGSize)size {
  if (self.next) {
    return [self.next addToInsets:insets forSize:size];

  } else {
    return insets;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)addToSize:(CGSize)size context:(BMTTStyleContext*)context {
  if (_next) {
    return [self.next addToSize:size context:context];

  } else {
    return size;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addStyle:(BMTTStyle*)style {
  if (_next) {
    [_next addStyle:style];

  } else {
    _next = [style retain];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)firstStyleOfClass:(Class)cls {
  if ([self isKindOfClass:cls]) {
    return self;

  } else {
    return [self.next firstStyleOfClass:cls];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)styleForPart:(NSString*)name {
  BMTTStyle* style = self;
  while (style) {
    if ([style isKindOfClass:[BMTTPartStyle class]]) {
      BMTTPartStyle* partStyle = (BMTTPartStyle*)style;
      if ([partStyle.name isEqualToString:name]) {
        return partStyle;
      }
    }
    style = style.next;
  }
  return nil;
}


@end
