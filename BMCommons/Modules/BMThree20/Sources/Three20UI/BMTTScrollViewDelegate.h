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

@class BMTTScrollView;

@protocol BMTTScrollViewDelegate <NSObject>

@required

- (void)scrollView:(BMTTScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex;

@optional

- (void)scrollViewWillRotate: (BMTTScrollView*)scrollView
               toOrientation: (UIInterfaceOrientation)orientation;

- (void)scrollViewDidRotate:(BMTTScrollView*)scrollView;

- (void)scrollViewWillBeginDragging:(BMTTScrollView*)scrollView;

- (void)scrollViewDidEndDragging:(BMTTScrollView*)scrollView willDecelerate:(BOOL)willDecelerate;

- (void)scrollViewWillBeginDecelerating:(BMTTScrollView*)scrollView;

- (void)scrollViewDidEndDecelerating:(BMTTScrollView*)scrollView;

- (BOOL)scrollViewShouldZoom:(BMTTScrollView*)scrollView;

- (void)scrollViewDidBeginZooming:(BMTTScrollView*)scrollView;

- (void)scrollViewDidEndZooming:(BMTTScrollView*)scrollView;

- (void)scrollViewDidScroll:(BMTTScrollView *)scrollView;

- (BOOL)scrollView:(BMTTScrollView *)scrollView flickedBoundary:(BOOL)right;

- (void)scrollView:(BMTTScrollView*)scrollView touchedDown:(UITouch*)touch;

- (void)scrollView:(BMTTScrollView*)scrollView touchedUpInside:(UITouch*)touch;

- (void)scrollView:(BMTTScrollView*)scrollView tapped:(UITouch*)touch;

- (void)scrollViewDidBeginHolding:(BMTTScrollView*)scrollView;

- (void)scrollViewDidEndHolding:(BMTTScrollView*)scrollView;

- (BOOL)scrollView:(BMTTScrollView*)scrollView
  shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end
