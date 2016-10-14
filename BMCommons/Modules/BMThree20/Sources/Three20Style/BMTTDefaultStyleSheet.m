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

#import "Three20Style/BMTTDefaultStyleSheet.h"

// Style
#import "Three20Style/BMTTGlobalStyle.h"
#import "Three20Style/BMTTStyle.h"
#import "Three20Style/UIColorAdditions.h"

// - Styles
#import "Three20Style/BMTTInsetStyle.h"
#import "Three20Style/BMTTShapeStyle.h"
#import "Three20Style/BMTTSolidFillStyle.h"
#import "Three20Style/BMTTTextStyle.h"
#import "Three20Style/BMTTImageStyle.h"
#import "Three20Style/BMTTSolidBorderStyle.h"
#import "Three20Style/BMTTShadowStyle.h"
#import "Three20Style/BMTTInnerShadowStyle.h"
#import "Three20Style/BMTTBevelBorderStyle.h"
#import "Three20Style/BMTTLinearGradientFillStyle.h"
#import "Three20Style/BMTTFourBorderStyle.h"
#import "Three20Style/BMTTLinearGradientBorderStyle.h"
#import "Three20Style/BMTTReflectiveFillStyle.h"
#import "Three20Style/BMTTBoxStyle.h"
#import "Three20Style/BMTTPartStyle.h"
#import "Three20Style/BMTTContentStyle.h"
#import "Three20Style/BMTTBlendStyle.h"

// - Shapes
#import "Three20Style/BMTTRectangleShape.h"
#import "Three20Style/BMTTRoundedRectangleShape.h"
#import "Three20Style/BMTTRoundedLeftArrowShape.h"
#import "Three20Style/BMTTRoundedRightArrowShape.h"

#import <BMCommons/BMCore.h>
#import <BMCommons/BMURLCache.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMTTDefaultStyleSheet


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)linkText:(UIControlState)state {
  if (state == UIControlStateHighlighted) {
    return
      [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(-3, -4, -3, -4) next:
      [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:4.5] next:
      [BMTTSolidFillStyle styleWithColor:[UIColor colorWithWhite:0.75 alpha:1] next:
      [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(3, 4, 3, 4) next:
      [BMTTTextStyle styleWithColor:self.linkTextColor next:nil]]]]];

  } else {
    return
      [BMTTTextStyle styleWithColor:self.linkTextColor next:nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)linkHighlighted {
  return
    [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:4.5] next:
    [BMTTSolidFillStyle styleWithColor:[UIColor colorWithWhite:0 alpha:0.25] next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)thumbView:(UIControlState)state {
  if (state & UIControlStateHighlighted) {
    return
      [BMTTImageStyle styleWithImageURL:nil defaultImage:nil
                    contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero next:
      [BMTTSolidBorderStyle styleWithColor:RGBACOLOR(0,0,0,0.2) width:1 next:
      [BMTTSolidFillStyle styleWithColor:RGBACOLOR(0,0,0,0.5) next:nil]]];

  } else {
    return
      [BMTTImageStyle styleWithImageURL:nil defaultImage:nil
                    contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero next:
      [BMTTSolidBorderStyle styleWithColor:RGBACOLOR(0,0,0,0.2) width:1 next:nil]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)toolbarButton:(UIControlState)state {
  return [self toolbarButtonForState:state
               shape:[BMTTRoundedRectangleShape shapeWithRadius:4.5]
               tintColor:BMTTSTYLEVAR(toolbarTintColor)
               font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)toolbarBackButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BMTTRoundedLeftArrowShape shapeWithRadius:4.5]
          tintColor:BMTTSTYLEVAR(toolbarTintColor)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)toolbarForwardButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BMTTRoundedRightArrowShape shapeWithRadius:4.5]
          tintColor:BMTTSTYLEVAR(toolbarTintColor)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)toolbarRoundButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BMTTRoundedRectangleShape shapeWithRadius:BMTT_ROUNDED]
          tintColor:BMTTSTYLEVAR(toolbarTintColor)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)blackToolbarButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BMTTRoundedRectangleShape shapeWithRadius:4.5]
          tintColor:RGBCOLOR(10, 10, 10)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)grayToolbarButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BMTTRoundedRectangleShape shapeWithRadius:4.5]
          tintColor:RGBCOLOR(40, 40, 40)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)blackToolbarForwardButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BMTTRoundedRightArrowShape shapeWithRadius:4.5]
          tintColor:RGBCOLOR(10, 10, 10)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)blackToolbarRoundButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BMTTRoundedRectangleShape shapeWithRadius:BMTT_ROUNDED]
          tintColor:RGBCOLOR(10, 10, 10)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)searchTextField {
  return
    [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:BMTT_ROUNDED] next:
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 0, 1, 0) next:
    [BMTTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.4) blur:0 offset:CGSizeMake(0, 1) next:
    [BMTTSolidFillStyle styleWithColor:(UIColor *)BMTTSTYLEVAR(backgroundColor) next:
    [BMTTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.4) blur:3 offset:CGSizeMake(0, 2) next:
    [BMTTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.25) shadow:RGBACOLOR(0,0,0,0.4)
                        width:1 lightSource:270 next:nil]]]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)searchBar {
  UIColor* color = BMTTSTYLEVAR(searchBarTintColor);
  UIColor* highlight = [color multiplyHue:0 saturation:0 value:1.2];
  UIColor* shadowColor = [color multiplyHue:0 saturation:0 value:0.82];
  return
    [BMTTLinearGradientFillStyle styleWithColor1:highlight color2:color next:
    [BMTTFourBorderStyle styleWithTop:nil right:nil bottom:shadowColor left:nil width:1 next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)searchBarBottom {
  UIColor* color = BMTTSTYLEVAR(searchBarTintColor);
  UIColor* highlight = [color multiplyHue:0 saturation:0 value:1.2];
  UIColor* shadowColor = [color multiplyHue:0 saturation:0 value:0.82];
  return
    [BMTTLinearGradientFillStyle styleWithColor1:highlight color2:color next:
    [BMTTFourBorderStyle styleWithTop:shadowColor right:nil bottom:nil left:nil width:1 next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)blackSearchBar {
  UIColor* highlight = [UIColor colorWithWhite:1 alpha:0.05];
  UIColor* mid = [UIColor colorWithWhite:0.4 alpha:0.6];
  UIColor* shadowColor = [UIColor colorWithWhite:0 alpha:0.8];
  return
    [BMTTLinearGradientFillStyle styleWithColor1:mid color2:shadowColor next:
    [BMTTFourBorderStyle styleWithTop:nil right:nil bottom:shadowColor left:nil width:1 next:
    [BMTTFourBorderStyle styleWithTop:nil right:nil bottom:highlight left:nil width:1 next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tableHeader {
  UIColor* color = BMTTSTYLEVAR(tableHeaderTintColor);
  UIColor* highlight = [color multiplyHue:0 saturation:0 value:1.1];
  return
    [BMTTLinearGradientFillStyle styleWithColor1:highlight color2:color next:
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(-1, 0, 0, 0) next:
    [BMTTFourBorderStyle styleWithTop:nil right:nil bottom:RGBACOLOR(0,0,0,0.15)
                       left:nil width:1 next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)pickerCell:(UIControlState)state {
  if (state & UIControlStateSelected) {
    return
      [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:BMTT_ROUNDED] next:
      [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
      [BMTTLinearGradientFillStyle styleWithColor1:RGBCOLOR(79, 144, 255)
                                 color2:RGBCOLOR(49, 90, 255) next:
      [BMTTFourBorderStyle styleWithTop:RGBCOLOR(53, 94, 255)
                         right:RGBCOLOR(53, 94, 255) bottom:RGBCOLOR(53, 94, 255)
                         left:RGBCOLOR(53, 94, 255) width:1 next:nil]]]];

   } else {
    return
     [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:BMTT_ROUNDED] next:
     [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
     [BMTTLinearGradientFillStyle styleWithColor1:RGBCOLOR(221, 231, 248)
                                color2:RGBACOLOR(188, 206, 241, 1) next:
     [BMTTLinearGradientBorderStyle styleWithColor1:RGBCOLOR(161, 187, 283)
                        color2:RGBCOLOR(118, 130, 214) width:1 next:nil]]]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)searchTableShadow {
  return
    [BMTTLinearGradientFillStyle styleWithColor1:RGBACOLOR(0, 0, 0, 0.18)
                               color2:[UIColor clearColor] next:
    [BMTTFourBorderStyle styleWithTop:RGBCOLOR(130, 130, 130) right:nil bottom:nil left:nil
                       width: 1 next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)blackBezel {
  return
    [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:10] next:
    [BMTTSolidFillStyle styleWithColor:RGBACOLOR(0, 0, 0, 0.7) next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)whiteBezel {
  return
    [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:10] next:
    [BMTTSolidFillStyle styleWithColor:RGBCOLOR(255, 255, 255) next:
    [BMTTSolidBorderStyle styleWithColor:RGBCOLOR(178, 178, 178) width:1 next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)blackBanner {
  return
    [BMTTSolidFillStyle styleWithColor:RGBACOLOR(0, 0, 0, 0.5) next:
    [BMTTFourBorderStyle styleWithTop:RGBCOLOR(0, 0, 0) right:nil bottom:nil left: nil width:1 next:
    [BMTTFourBorderStyle styleWithTop:[UIColor colorWithWhite:1 alpha:0.2] right:nil bottom:nil
                       left: nil width:1 next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)badgeWithFontSize:(CGFloat)fontSize {
  return
    [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:BMTT_ROUNDED] next:
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
    [BMTTShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.8) blur:3 offset:CGSizeMake(0, 4) next:
    [BMTTReflectiveFillStyle styleWithColor:RGBCOLOR(221, 17, 27) next:
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(-1, -1, -1, -1) next:
    [BMTTSolidBorderStyle styleWithColor:[UIColor whiteColor] width:2 next:
    [BMTTBoxStyle styleWithPadding:UIEdgeInsetsMake(1, 7, 2, 7) next:
    [BMTTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:fontSize]
                 color:[UIColor whiteColor] next:nil]]]]]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)miniBadge {
  return [self badgeWithFontSize:12];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)badge {
  return [self badgeWithFontSize:15];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)largeBadge {
  return [self badgeWithFontSize:17];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabBar {
  UIColor* border = [BMTTSTYLEVAR(tabBarTintColor) multiplyHue:0 saturation:0 value:0.7];
  return
    [BMTTSolidFillStyle styleWithColor:BMTTSTYLEVAR(tabBarTintColor) next:
    [BMTTFourBorderStyle styleWithTop:nil right:nil bottom:border left:nil width:1 next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabStrip {
  UIColor* border = [BMTTSTYLEVAR(tabTintColor) multiplyHue:0 saturation:0 value:0.4];
  return
    [BMTTReflectiveFillStyle styleWithColor:BMTTSTYLEVAR(tabTintColor) next:
    [BMTTFourBorderStyle styleWithTop:nil right:nil bottom:border left:nil width:1 next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabGrid {
  UIColor* color = BMTTSTYLEVAR(tabTintColor);
  UIColor* lighter = [color multiplyHue:1 saturation:0.9 value:1.1];

  UIColor* highlight = RGBACOLOR(255, 255, 255, 0.7);
  UIColor* shadowColor = [color multiplyHue:1 saturation:1.1 value:0.86];
  return
    [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:8] next:
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(0,-1,-1,-2) next:
    [BMTTShadowStyle styleWithColor:highlight blur:1 offset:CGSizeMake(0, 1) next:
    [BMTTLinearGradientFillStyle styleWithColor1:lighter color2:color next:
    [BMTTSolidBorderStyle styleWithColor:shadowColor width:1 next:nil]]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabGridTabImage:(UIControlState)state {
  return
    [BMTTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeLeft
                  size:CGSizeZero next:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabGridTab:(UIControlState)state corner:(short)corner {
  BMTTShape* shape = nil;
  if (corner == 1) {
    shape = [BMTTRoundedRectangleShape shapeWithTopLeft:8 topRight:0 bottomRight:0 bottomLeft:0];

  } else if (corner == 2) {
    shape = [BMTTRoundedRectangleShape shapeWithTopLeft:0 topRight:8 bottomRight:0 bottomLeft:0];

  } else if (corner == 3) {
    shape = [BMTTRoundedRectangleShape shapeWithTopLeft:0 topRight:0 bottomRight:8 bottomLeft:0];

  } else if (corner == 4) {
    shape = [BMTTRoundedRectangleShape shapeWithTopLeft:0 topRight:0 bottomRight:0 bottomLeft:8];

  } else if (corner == 5) {
    shape = [BMTTRoundedRectangleShape shapeWithTopLeft:8 topRight:0 bottomRight:0 bottomLeft:8];

  } else if (corner == 6) {
    shape = [BMTTRoundedRectangleShape shapeWithTopLeft:0 topRight:8 bottomRight:8 bottomLeft:0];

  } else {
    shape = [BMTTRectangleShape shape];
  }

  UIColor* highlight = RGBACOLOR(255, 255, 255, 0.7);
  UIColor* shadowColor = [BMTTSTYLEVAR(tabTintColor) multiplyHue:1 saturation:1.1 value:0.88];

  if (state == UIControlStateSelected) {
    return
      [BMTTShapeStyle styleWithShape:shape next:
      [BMTTSolidFillStyle styleWithColor:RGBCOLOR(150, 168, 191) next:
      [BMTTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.6) blur:3 offset:CGSizeMake(0, 0) next:
      [BMTTBoxStyle styleWithPadding:UIEdgeInsetsMake(11, 10, 9, 10) next:
      [BMTTPartStyle styleWithName:@"image" style:[self tabGridTabImage:state] next:
      [BMTTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:11]  color:RGBCOLOR(255, 255, 255)
                   minimumFontSize:8 shadowColor:RGBACOLOR(0,0,0,0.1) shadowOffset:CGSizeMake(-1,-1)
                   next:nil]]]]]];

  } else {
    return
      [BMTTShapeStyle styleWithShape:shape next:
      [BMTTBevelBorderStyle styleWithHighlight:highlight
                                      shadow:shadowColor
                                       width:1
                                 lightSource:125 next:
      [BMTTBoxStyle styleWithPadding:UIEdgeInsetsMake(11, 10, 9, 10) next:
      [BMTTPartStyle styleWithName:@"image" style:[self tabGridTabImage:state] next:
      [BMTTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:11]  color:self.linkTextColor
                   minimumFontSize:8 shadowColor:[UIColor colorWithWhite:255 alpha:0.9]
                   shadowOffset:CGSizeMake(0, -1) next:nil]]]]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabGridTabTopLeft:(UIControlState)state {
  return [self tabGridTab:state corner:1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabGridTabTopRight:(UIControlState)state {
  return [self tabGridTab:state corner:2];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabGridTabBottomRight:(UIControlState)state {
  return [self tabGridTab:state corner:3];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabGridTabBottomLeft:(UIControlState)state {
  return [self tabGridTab:state corner:4];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabGridTabLeft:(UIControlState)state {
  return [self tabGridTab:state corner:5];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabGridTabRight:(UIControlState)state {
  return [self tabGridTab:state corner:6];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabGridTabCenter:(UIControlState)state {
  return [self tabGridTab:state corner:0];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tab:(UIControlState)state {
  if (state == UIControlStateSelected) {
    UIColor* border = [BMTTSTYLEVAR(tabBarTintColor) multiplyHue:0 saturation:0 value:0.7];

    return
      [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithTopLeft:4.5 topRight:4.5
                                                            bottomRight:0 bottomLeft:0] next:
      [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(5, 1, 0, 1) next:
      [BMTTReflectiveFillStyle styleWithColor:BMTTSTYLEVAR(tabTintColor) next:
      [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(-1, -1, 0, -1) next:
      [BMTTFourBorderStyle styleWithTop:border right:border bottom:nil left:border width:1 next:
      [BMTTBoxStyle styleWithPadding:UIEdgeInsetsMake(6, 12, 2, 12) next:
      [BMTTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:14]  color:BMTTSTYLEVAR(textColor)
                   minimumFontSize:8 shadowColor:[UIColor colorWithWhite:1 alpha:0.8]
                   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];

  } else {
    return
      [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(5, 1, 1, 1) next:
      [BMTTBoxStyle styleWithPadding:UIEdgeInsetsMake(6, 12, 2, 12) next:
      [BMTTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:14]  color:[UIColor whiteColor]
                   minimumFontSize:8 shadowColor:[UIColor colorWithWhite:0 alpha:0.6]
                   shadowOffset:CGSizeMake(0, -1) next:nil]]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabRound:(UIControlState)state {
  if (state == UIControlStateSelected) {
    return
      [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:BMTT_ROUNDED] next:
      [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(9, 1, 8, 1) next:
      [BMTTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.8) blur:0 offset:CGSizeMake(0, 1) next:
      [BMTTReflectiveFillStyle styleWithColor:BMTTSTYLEVAR(tabBarTintColor) next:
      [BMTTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.3) blur:1 offset:CGSizeMake(1, 1) next:
      [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(-1, -1, -1, -1) next:
      [BMTTBoxStyle styleWithPadding:UIEdgeInsetsMake(0, 10, 0, 10) next:
      [BMTTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:13]  color:[UIColor whiteColor]
                   minimumFontSize:8 shadowColor:[UIColor colorWithWhite:0 alpha:0.5]
                   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]]];

  } else {
    return
      [BMTTBoxStyle styleWithPadding:UIEdgeInsetsMake(0, 10, 0, 10) next:
      [BMTTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:13]  color:self.linkTextColor
                   minimumFontSize:8 shadowColor:[UIColor colorWithWhite:1 alpha:0.9]
                   shadowOffset:CGSizeMake(0, -1) next:nil]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabOverflowLeft {
  UIImage* image = BMIMAGE(@"bundle://BMThree20.bundle/overflowLeft.png");
  BMTTImageStyle *style = [BMTTImageStyle styleWithImage:image next:nil];
  style.contentMode = UIViewContentModeCenter;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)tabOverflowRight {
  UIImage* image = BMIMAGE(@"bundle://BMThree20.bundle/overflowRight.png");
  BMTTImageStyle *style = [BMTTImageStyle styleWithImage:image next:nil];
  style.contentMode = UIViewContentModeCenter;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)rounded {
  return
    [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:8] next:
    [BMTTContentStyle styleWithNext:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)postTextEditor {
  return
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(6, 5, 6, 5) next:
    [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:15] next:
    [BMTTSolidFillStyle styleWithColor:[UIColor whiteColor] next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)photoCaption {
  return
    [BMTTSolidFillStyle styleWithColor:[UIColor colorWithWhite:0 alpha:0.5] next:
    [BMTTFourBorderStyle styleWithTop:RGBACOLOR(0, 0, 0, 0.5) width:1 next:
    [BMTTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 8, 8, 8) next:
    [BMTTTextStyle styleWithFont: BMTTSTYLEVAR(photoCaptionFont)
                         color: BMTTSTYLEVAR(photoCaptionTextColor)
               minimumFontSize: 0
                   shadowColor: BMTTSTYLEVAR(photoCaptionTextShadowColor)
                  shadowOffset: BMTTSTYLEVAR(photoCaptionTextShadowOffset)
                 textAlignment: NSTextAlignmentCenter
             verticalAlignment: UIControlContentVerticalAlignmentCenter
                 lineBreakMode: NSLineBreakByTruncatingTail
                 numberOfLines: 6
                          next: nil]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)photoStatusLabel {
  return
    [BMTTSolidFillStyle styleWithColor:[UIColor colorWithWhite:0 alpha:0.5] next:
    [BMTTBoxStyle styleWithPadding:UIEdgeInsetsMake(20, 8, 20, 8) next:
    [BMTTTextStyle styleWithFont:BMTTSTYLEVAR(tableFont) color:RGBCOLOR(200, 200, 200)
                 minimumFontSize:0 shadowColor:[UIColor colorWithWhite:0 alpha:0.9]
                 shadowOffset:CGSizeMake(0, -1) next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)pageDot:(UIControlState)state {
  if (state == UIControlStateSelected) {
    return [self pageDotWithColor:[UIColor whiteColor]];

  } else {
    return [self pageDotWithColor:RGBCOLOR(77, 77, 77)];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)launcherButton:(UIControlState)state {
  return
    [BMTTPartStyle styleWithName:@"image" style:BMTTSTYLESTATE(launcherButtonImage:, state) next:
    [BMTTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:11] color:RGBCOLOR(180, 180, 180)
                 minimumFontSize:11 shadowColor:nil
                 shadowOffset:CGSizeZero next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)launcherButtonImage:(UIControlState)state {
  BMTTStyle* style =
    [BMTTBoxStyle styleWithMargin:UIEdgeInsetsMake(-7, 0, 11, 0) next:
    [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:8] next:
    [BMTTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeCenter
                  size:CGSizeZero next:nil]]];

  if (state == UIControlStateHighlighted || state == UIControlStateSelected) {
      [style addStyle:
        [BMTTBlendStyle styleWithBlend:kCGBlendModeSourceAtop next:
        [BMTTSolidFillStyle styleWithColor:RGBACOLOR(0,0,0,0.5) next:nil]]];
  }

  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)launcherCloseButtonImage:(UIControlState)state {
  return
    [BMTTBoxStyle styleWithMargin:UIEdgeInsetsMake(-2, 0, 0, 0) next:
    [BMTTImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeCenter
                  size:CGSizeMake(10,10) next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)launcherCloseButton:(UIControlState)state {
  return
    [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:BMTT_ROUNDED] next:
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
    [BMTTShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.5) blur:2 offset:CGSizeMake(0, 3) next:
    [BMTTSolidFillStyle styleWithColor:[UIColor blackColor] next:
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(-1, -1, -1, -1) next:
    [BMTTSolidBorderStyle styleWithColor:[UIColor whiteColor] width:2 next:
    [BMTTPartStyle styleWithName:@"image" style:BMTTSTYLE(launcherCloseButtonImage:) next:
    nil]]]]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)launcherPageDot:(UIControlState)state {
  return [self pageDot:state];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)textBar {
  return
    [BMTTLinearGradientFillStyle styleWithColor1:RGBCOLOR(237, 239, 241)
                               color2:RGBCOLOR(206, 208, 212) next:
    [BMTTFourBorderStyle styleWithTop:RGBCOLOR(187, 189, 190)
                              right:nil bottom:nil left:nil width:1 next:
    [BMTTFourBorderStyle styleWithTop:RGBCOLOR(255, 255, 255)
                              right:nil bottom:nil left:nil width:1
                       next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)textBarFooter {
  return
    [BMTTLinearGradientFillStyle styleWithColor1:RGBCOLOR(206, 208, 212)
                               color2:RGBCOLOR(184, 186, 190) next:
    [BMTTFourBorderStyle styleWithTop:RGBCOLOR(161, 161, 161)
                              right:nil bottom:nil left:nil width:1 next:
    [BMTTFourBorderStyle styleWithTop:RGBCOLOR(230, 232, 235)
                              right:nil bottom:nil left:nil width:1
                       next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)textBarTextField {
  return
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(6, 0, 3, 6) next:
    [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:12.5] next:
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(1, 0, 1, 0) next:
    [BMTTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.4) blur:0 offset:CGSizeMake(0, 1) next:
    [BMTTSolidFillStyle styleWithColor:(UIColor *)BMTTSTYLEVAR(backgroundColor) next:
    [BMTTInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.4) blur:3 offset:CGSizeMake(0, 2) next:
    [BMTTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.25) shadow:RGBACOLOR(0,0,0,0.4)
                        width:1 lightSource:270 next:nil]]]]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)textBarPostButton:(UIControlState)state {
  UIColor* fillColor = state == UIControlStateHighlighted
                       ? RGBCOLOR(19, 61, 126)
                       : RGBCOLOR(31, 100, 206);
  UIColor* textColor = state == UIControlStateDisabled
                       ? RGBACOLOR(255, 255, 255, 0.5)
                       : RGBCOLOR(255, 255, 255);
  return
    [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:13] next:
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 1, 0) next:
    [BMTTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.5) blur:0 offset:CGSizeMake(0, 1) next:
    [BMTTReflectiveFillStyle styleWithColor:fillColor next:
    [BMTTLinearGradientBorderStyle styleWithColor1:fillColor
                                 color2:RGBCOLOR(14, 83, 187) width:1 next:
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
    [BMTTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 9, 8, 9) next:
    [BMTTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:15]
                 color:textColor shadowColor:[UIColor colorWithWhite:0 alpha:0.3]
                 shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public colors


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Common styles


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)textColor {
  return [UIColor blackColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)highlightedTextColor {
  return [UIColor whiteColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)font {
  return [UIFont systemFontOfSize:14];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)backgroundColor {
  return [UIColor whiteColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)navigationBarTintColor {
  return RGBCOLOR(119, 140, 168);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)navigationBarTextTintColor {
    return [UIColor whiteColor];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)toolbarTintColor {
  return RGBCOLOR(109, 132, 162);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)searchBarTintColor {
  return RGBCOLOR(200, 200, 200);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Tables


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tablePlainBackgroundColor {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableGroupedBackgroundColor {
  return [UIColor groupTableViewBackgroundColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)searchTableBackgroundColor {
  return RGBCOLOR(235, 235, 235);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)searchTableSeparatorColor {
  return [UIColor colorWithWhite:0.85 alpha:1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table Items


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)linkTextColor {
  return RGBCOLOR(87, 107, 149);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)timestampTextColor {
  return RGBCOLOR(36, 112, 216);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)moreLinkTextColor {
  return RGBCOLOR(36, 112, 216);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table Headers


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableHeaderTextColor {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableHeaderShadowColor {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)tableHeaderShadowOffset {
  return CGSizeMake(0, 1);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableHeaderTintColor {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Photo Captions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)photoCaptionTextColor {
  return [UIColor whiteColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)photoCaptionTextShadowColor {
  return [UIColor colorWithWhite:0 alpha:0.9];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)photoCaptionTextShadowOffset {
  return CGSizeMake(0, 1);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Unsorted


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)screenBackgroundColor {
  return [UIColor colorWithWhite:0 alpha:0.8];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableActivityTextColor {
  return RGBCOLOR(99, 109, 125);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableErrorTextColor {
  return RGBCOLOR(96, 103, 111);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableSubTextColor {
  return RGBCOLOR(79, 89, 105);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableTitleTextColor {
  return RGBCOLOR(99, 109, 125);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tabBarTintColor {
  return RGBCOLOR(119, 140, 168);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tabTintColor {
  return RGBCOLOR(228, 230, 235);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)messageFieldTextColor {
  return [UIColor colorWithWhite:0.5 alpha:1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)messageFieldSeparatorColor {
  return [UIColor colorWithWhite:0.7 alpha:1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)thumbnailBackgroundColor {
  return [UIColor colorWithWhite:0.95 alpha:1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)postButtonColor {
  return RGBCOLOR(117, 144, 181);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public fonts


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)buttonFont {
  return [UIFont boldSystemFontOfSize:12];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableFont {
  return [UIFont boldSystemFontOfSize:17];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableSmallFont {
  return [UIFont boldSystemFontOfSize:15];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableTitleFont {
  return [UIFont boldSystemFontOfSize:13];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableTimestampFont {
  return [UIFont systemFontOfSize:13];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableButtonFont {
  return [UIFont boldSystemFontOfSize:13];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableSummaryFont {
  return [UIFont systemFontOfSize:17];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableHeaderPlainFont {
  return [UIFont boldSystemFontOfSize:16];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableHeaderGroupedFont {
  return [UIFont boldSystemFontOfSize:18];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) tableBannerViewHeight {
  return 22;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)photoCaptionFont {
  return [UIFont boldSystemFontOfSize:12];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)messageFont {
  return [UIFont systemFontOfSize:15];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)errorTitleFont {
  return [UIFont boldSystemFontOfSize:18];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)errorSubtitleFont {
  return [UIFont boldSystemFontOfSize:12];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)activityLabelFont {
  return [UIFont systemFontOfSize:17];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)activityBannerFont {
  return [UIFont boldSystemFontOfSize:11];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCellSelectionStyle)tableSelectionStyle {
  return UITableViewCellSelectionStyleBlue;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)toolbarButtonColorWithTintColor:(UIColor*)color forState:(UIControlState)state {
  if (state & UIControlStateHighlighted || state & UIControlStateSelected) {
    if (color.value < 0.2) {
      return [color addHue:0 saturation:0 value:0.2];

    } else if (color.saturation > 0.3) {
      return [color multiplyHue:1 saturation:1 value:0.4];

    } else {
      return [color multiplyHue:1 saturation:2.3 value:0.64];
    }

  } else {
    if (color.saturation < 0.5) {
      return [color multiplyHue:1 saturation:1.6 value:0.97];

    } else {
      return [color multiplyHue:1 saturation:1.25 value:0.75];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)toolbarButtonTextColorForState:(UIControlState)state {
  if (state & UIControlStateDisabled) {
    return [UIColor colorWithWhite:1 alpha:0.4];

  } else {
    return [UIColor whiteColor];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)selectionFillStyle:(BMTTStyle*)next {
  return [BMTTLinearGradientFillStyle styleWithColor1:RGBCOLOR(5,140,245)
                                    color2:RGBCOLOR(1,93,230) next:next];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)toolbarButtonForState:(UIControlState)state shape:(BMTTShape*)shape
            tintColor:(UIColor*)tintColor font:(UIFont*)font {
  UIColor* stateTintColor = [self toolbarButtonColorWithTintColor:tintColor forState:state];
  UIColor* stateTextColor = [self toolbarButtonTextColorForState:state];

  return
    [BMTTShapeStyle styleWithShape:shape next:
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 1, 0) next:
    [BMTTShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.18) blur:0 offset:CGSizeMake(0, 1) next:
    [BMTTReflectiveFillStyle styleWithColor:stateTintColor next:
    [BMTTBevelBorderStyle styleWithHighlight:[stateTintColor multiplyHue:1 saturation:0.9 value:0.7]
                        shadow:[stateTintColor multiplyHue:1 saturation:0.5 value:0.6]
                        width:1 lightSource:270 next:
    [BMTTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
    [BMTTBevelBorderStyle styleWithHighlight:nil shadow:RGBACOLOR(0,0,0,0.15)
                        width:1 lightSource:270 next:
    [BMTTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 8, 8, 8) next:
    [BMTTImageStyle styleWithImageURL:nil defaultImage:nil
                  contentMode:UIViewContentModeScaleToFill size:CGSizeZero next:
    [BMTTTextStyle styleWithFont:font
                 color:stateTextColor shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
                 shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BMTTStyle*)pageDotWithColor:(UIColor*)color {
  return
    [BMTTBoxStyle styleWithMargin:UIEdgeInsetsMake(0,0,0,10) padding:UIEdgeInsetsMake(6,6,0,0) next:
    [BMTTShapeStyle styleWithShape:[BMTTRoundedRectangleShape shapeWithRadius:2.5] next:
    [BMTTSolidFillStyle styleWithColor:color next:nil]]];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMTTDefaultStyleSheet (BMTTDragRefreshHeader)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableRefreshHeaderLastUpdatedFont {
  return [UIFont systemFontOfSize:12.0f];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableRefreshHeaderStatusFont {
  return [UIFont boldSystemFontOfSize:14.0f];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableRefreshHeaderBackgroundColor {
  return RGBCOLOR(226, 231, 237);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableRefreshHeaderTextColor {
  return RGBCOLOR(109, 128, 153);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableRefreshHeaderTextShadowColor {
  return [[UIColor whiteColor] colorWithAlphaComponent:0.9];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)tableRefreshHeaderTextShadowOffset {
  return CGSizeMake(0.0f, 1.0f);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)tableRefreshHeaderArrowImage {
  return BMIMAGE(@"bundle://BMThree20.bundle/blueArrow.png");
}


@end
