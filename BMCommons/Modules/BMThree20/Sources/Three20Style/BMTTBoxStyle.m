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

#import "Three20Style/BMTTBoxStyle.h"

// Style
#import "Three20Style/BMTTStyleContext.h"

// Core
#import "Three20Core/BMTTGlobalCoreRects.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMTTBoxStyle

@synthesize margin    = _margin;
@synthesize padding   = _padding;
@synthesize minSize   = _minSize;
@synthesize position  = _position;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(BMTTStyle*)next {
  if (self = [super initWithNext:next]) {
    _margin = UIEdgeInsetsZero;
    _padding = UIEdgeInsetsZero;
    _minSize = CGSizeZero;
    _position = BMTTPositionStatic;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BMTTBoxStyle*)styleWithMargin:(UIEdgeInsets)margin next:(BMTTStyle*)next {
  BMTTBoxStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.margin = margin;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BMTTBoxStyle*)styleWithPadding:(UIEdgeInsets)padding next:(BMTTStyle*)next {
  BMTTBoxStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.padding = padding;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BMTTBoxStyle*)styleWithFloats:(BMTTPosition)position next:(BMTTStyle*)next {
  BMTTBoxStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.position = position;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BMTTBoxStyle*)styleWithMargin:(UIEdgeInsets)margin padding:(UIEdgeInsets)padding
                          next:(BMTTStyle*)next {
  BMTTBoxStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.margin = margin;
  style.padding = padding;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BMTTBoxStyle*)styleWithMargin:(UIEdgeInsets)margin padding:(UIEdgeInsets)padding
                       minSize:(CGSize)minSize position:(BMTTPosition)position next:(BMTTStyle*)next {
  BMTTBoxStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.margin = margin;
  style.padding = padding;
  style.minSize = minSize;
  style.position = position;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BMTTStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(BMTTStyleContext*)context {
  context.contentFrame = BMTTRectInset(context.contentFrame, _padding);
  [self.next draw:context];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)addToSize:(CGSize)size context:(BMTTStyleContext*)context {
  size.width += _padding.left + _padding.right;
  size.height += _padding.top + _padding.bottom;

  if (_next) {
    return [self.next addToSize:size context:context];

  } else {
    return size;
  }
}


@end
