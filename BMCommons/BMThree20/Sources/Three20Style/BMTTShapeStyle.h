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
#import <BMThree20/Three20Style/BMTTStyle.h>

@class BMTTShape;

/**
 * Causes all layers going forward to use a particular shape.
 */
@interface BMTTShapeStyle : BMTTStyle {
  BMTTShape* _shape;
}

@property (nonatomic, retain) BMTTShape* shape;

+ (BMTTShapeStyle*)styleWithShape:(BMTTShape*)shape next:(BMTTStyle*)next;

@end
