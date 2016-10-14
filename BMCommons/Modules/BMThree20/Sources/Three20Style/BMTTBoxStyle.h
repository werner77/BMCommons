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
#import <BMCommons/Three20Style/BMTTStyle.h>
#import <BMCommons/Three20Style/BMTTPosition.h>

@interface BMTTBoxStyle : BMTTStyle {
  UIEdgeInsets  _margin;
  UIEdgeInsets  _padding;
  CGSize        _minSize;
  BMTTPosition    _position;
}

@property (nonatomic) UIEdgeInsets  margin;
@property (nonatomic) UIEdgeInsets  padding;
@property (nonatomic) CGSize        minSize;
@property (nonatomic) BMTTPosition    position;

+ (BMTTBoxStyle*)styleWithMargin:(UIEdgeInsets)margin next:(BMTTStyle*)next;
+ (BMTTBoxStyle*)styleWithPadding:(UIEdgeInsets)padding next:(BMTTStyle*)next;
+ (BMTTBoxStyle*)styleWithFloats:(BMTTPosition)position next:(BMTTStyle*)next;
+ (BMTTBoxStyle*)styleWithMargin:(UIEdgeInsets)margin padding:(UIEdgeInsets)padding
                          next:(BMTTStyle*)next;
+ (BMTTBoxStyle*)styleWithMargin:(UIEdgeInsets)margin padding:(UIEdgeInsets)padding
                       minSize:(CGSize)minSize position:(BMTTPosition)position next:(BMTTStyle*)next;

@end
