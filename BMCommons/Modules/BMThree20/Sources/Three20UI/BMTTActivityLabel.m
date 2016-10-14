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

#import "Three20UI/BMTTActivityLabel.h"

// UI
#import "Three20UI/BMTTView.h"
#import "Three20UI/UIViewAdditions.h"

// UINavigator
#import "Three20UINavigator/BMTTGlobalNavigatorMetrics.h"

// Style
#import "Three20Style/UIFontAdditions.h"
#import "Three20Style/BMTTStyle.h"
#import "Three20Style/BMTTShapeStyle.h"
#import "Three20Style/BMTTSolidFillStyle.h"
#import "Three20Style/BMTTRoundedRectangleShape.h"
#import "Three20Style/BMTTSolidBorderStyle.h"
#import "Three20Style/BMTTFourBorderStyle.h"
#import "Three20Style/BMTTGlobalStyle.h"

// Core
#import "Three20Core/BMTTCorePreprocessorMacros.h"

static CGFloat kMargin          = 10;
static CGFloat kPadding         = 15;
static CGFloat kBannerPadding   = 8;
static CGFloat kSpacing         = 6;
static CGFloat kProgressMargin  = 6;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMTTActivityLabel

@synthesize style             = _style;
@synthesize progress          = _progress;
@synthesize smoothesProgress  = _smoothesProgress;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame style:(BMTTActivityLabelStyle)style text:(NSString*)text {
  if (self = [super initWithFrame:frame]) {
    _style = style;
    _progress = 0;
    _smoothesProgress = NO;
    _smoothTimer =nil;
    _progressView = nil;

    _bezelView = [[BMTTView alloc] init];
    if (_style == BMTTActivityLabelStyleBlackBezel) {
      _bezelView.backgroundColor = [UIColor clearColor];
      _bezelView.style = BMTTSTYLE(blackBezel);
      self.backgroundColor = [UIColor clearColor];

    } else if (_style == BMTTActivityLabelStyleWhiteBezel) {
      _bezelView.backgroundColor = [UIColor clearColor];
      _bezelView.style = BMTTSTYLE(whiteBezel);
      self.backgroundColor = [UIColor clearColor];

    } else if (_style == BMTTActivityLabelStyleWhiteBox) {
      _bezelView.backgroundColor = [UIColor clearColor];
      self.backgroundColor = [UIColor whiteColor];

    } else if (_style == BMTTActivityLabelStyleBlackBox) {
      _bezelView.backgroundColor = [UIColor clearColor];
      self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];

    } else if (_style == BMTTActivityLabelStyleBlackBanner) {
      _bezelView.backgroundColor = [UIColor clearColor];
      _bezelView.style = BMTTSTYLE(blackBanner);
      self.backgroundColor = [UIColor clearColor];

    } else {
      _bezelView.backgroundColor = [UIColor clearColor];
      self.backgroundColor = [UIColor clearColor];
    }

    self.autoresizingMask =
      UIViewAutoresizingFlexibleWidth |
      UIViewAutoresizingFlexibleHeight;

    _label = [[UILabel alloc] init];
    _label.text = text;
    _label.backgroundColor = [UIColor clearColor];
    _label.lineBreakMode = NSLineBreakByTruncatingTail;

    if (_style == BMTTActivityLabelStyleWhite) {
      _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                                            UIActivityIndicatorViewStyleWhite];
      _label.font = BMTTSTYLEVAR(activityLabelFont);
      _label.textColor = [UIColor whiteColor];

    } else if (_style == BMTTActivityLabelStyleGray
               || _style == BMTTActivityLabelStyleWhiteBox
               || _style == BMTTActivityLabelStyleWhiteBezel) {
      _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                                            UIActivityIndicatorViewStyleGray];
      _label.font = BMTTSTYLEVAR(activityLabelFont);
      _label.textColor = BMTTSTYLEVAR(tableActivityTextColor);

    } else if (_style == BMTTActivityLabelStyleBlackBezel || _style == BMTTActivityLabelStyleBlackBox) {
      _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                                            UIActivityIndicatorViewStyleWhiteLarge];
      _activityIndicator.frame = CGRectMake(0, 0, 24, 24);
      _label.font = BMTTSTYLEVAR(activityLabelFont);
      _label.textColor = [UIColor whiteColor];
      _label.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
      _label.shadowOffset = CGSizeMake(1, 1);

    } else if (_style == BMTTActivityLabelStyleBlackBanner) {
      _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                                            UIActivityIndicatorViewStyleWhite];
      _label.font = BMTTSTYLEVAR(activityBannerFont);
      _label.textColor = [UIColor whiteColor];
      _label.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
      _label.shadowOffset = CGSizeMake(1, 1);
    }

    [self addSubview:_bezelView];
    [_bezelView addSubview:_activityIndicator];
    [_bezelView addSubview:_label];
    [_activityIndicator startAnimating];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame style:(BMTTActivityLabelStyle)style {
  if (self = [self initWithFrame:frame style:style text:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(BMTTActivityLabelStyle)style {
  if (self = [self initWithFrame:CGRectZero style:style text:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if (self = [self initWithFrame:frame style:BMTTActivityLabelStyleWhiteBox text:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BMTT_INVALIDATE_TIMER(_smoothTimer);
  BMTT_RELEASE_SAFELY(_bezelView);
  BMTT_RELEASE_SAFELY(_progressView);
  BMTT_RELEASE_SAFELY(_activityIndicator);
  BMTT_RELEASE_SAFELY(_label);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  CGSize textSize = [_label.text sizeWithFont:_label.font];

  CGFloat indicatorSize = 0;
  [_activityIndicator sizeToFit];
  if (_activityIndicator.isAnimating) {
    if (_activityIndicator.height > textSize.height) {
      indicatorSize = textSize.height;

    } else {
      indicatorSize = _activityIndicator.height;
    }
  }

  CGFloat contentWidth = indicatorSize + kSpacing + textSize.width;
  CGFloat contentHeight = textSize.height > indicatorSize ? textSize.height : indicatorSize;

  if (_progressView) {
    [_progressView sizeToFit];
    contentHeight += _progressView.height + kSpacing;
  }

  CGFloat margin, padding, bezelWidth, bezelHeight;
  if (_style == BMTTActivityLabelStyleBlackBezel || _style == BMTTActivityLabelStyleWhiteBezel) {
    margin = kMargin;
    padding = kPadding;
    bezelWidth = contentWidth + padding*2;
    bezelHeight = contentHeight + padding*2;

  } else {
    margin = 0;
    padding = kBannerPadding;
    bezelWidth = self.width;
    bezelHeight = self.height;
  }

  CGFloat maxBevelWidth = BMTTScreenBounds().size.width - margin*2;
  if (bezelWidth > maxBevelWidth) {
    bezelWidth = maxBevelWidth;
    contentWidth = bezelWidth - (kSpacing + indicatorSize);
  }

  CGFloat textMaxWidth = (bezelWidth - (indicatorSize + kSpacing)) - padding*2;
  CGFloat textWidth = textSize.width;
  if (textWidth > textMaxWidth) {
    textWidth = textMaxWidth;
  }

  _bezelView.frame = CGRectMake(floor(self.width/2 - bezelWidth/2),
                                floor(self.height/2 - bezelHeight/2),
                                bezelWidth, bezelHeight);

  CGFloat y = padding + floor((bezelHeight - padding*2)/2 - contentHeight/2);

  if (_progressView) {
    if (_style == BMTTActivityLabelStyleBlackBanner) {
      y += kBannerPadding/2;
    }
    _progressView.frame = CGRectMake(kProgressMargin, y,
                                     bezelWidth - kProgressMargin*2, _progressView.height);
    y += _progressView.height + kSpacing-1;
  }

  _label.frame = CGRectMake(floor((bezelWidth/2 - contentWidth/2) + indicatorSize + kSpacing), y,
                            textWidth, textSize.height);

  _activityIndicator.frame = CGRectMake(_label.left - (indicatorSize+kSpacing), y,
                                        indicatorSize, indicatorSize);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
  CGFloat padding;
  if (_style == BMTTActivityLabelStyleBlackBezel || _style == BMTTActivityLabelStyleWhiteBezel) {
    padding = kPadding;

  } else {
    padding = kBannerPadding;
  }

  CGFloat height = _label.font.ttLineHeight + padding*2;
  if (_progressView) {
    height += _progressView.height + kSpacing;
  }

  return CGSizeMake(size.width, height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)smoothTimer {
  if (_progressView.progress < _progress) {
    _progressView.progress += 0.01;

  } else {
    BMTT_INVALIDATE_TIMER(_smoothTimer);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)text {
  return _label.text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setText:(NSString*)text {
  _label.text = text;
  [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)font {
  return _label.font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font {
  _label.font = font;
  [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isAnimating {
  return _activityIndicator.isAnimating;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setIsAnimating:(BOOL)isAnimating {
  if (isAnimating) {
    [_activityIndicator startAnimating];

  } else {
    [_activityIndicator stopAnimating];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setProgress:(float)progress {
  _progress = progress;

  if (!_progressView) {
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.progress = 0;
    [_bezelView addSubview:_progressView];
    [self setNeedsLayout];
  }

  if (_smoothesProgress) {
    if (!_smoothTimer) {
      _smoothTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self
                              selector:@selector(smoothTimer) userInfo:nil repeats:YES];
    }

  } else {
    _progressView.progress = progress;
  }
}


@end
