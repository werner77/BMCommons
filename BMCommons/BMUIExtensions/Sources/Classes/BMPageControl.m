//
//  BMPageControl.m
//  BMCommons
//
//  Created by Werner Altewischer on 04/11/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMPageControl.h"

#define kDotSize 6
#define kDotSpacing 10
#define kInactiveDotAlpha 0.3

@implementation BMPageControl {
@private
	NSInteger _numberOfPages;
	NSInteger _currentPage;
	NSInteger _displayedPage;
	BOOL _hidesForSinglePage;
	BOOL _defersCurrentPageDisplay;
	UIColor *_dotColor;
}

@synthesize defersCurrentPageDisplay = _defersCurrentPageDisplay;
@synthesize dotColor = _dotColor;

- (void)setupView {
	self.opaque = NO;
	self.contentMode = UIViewContentModeRedraw;
	self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)aRect {
	if (self = [super initWithFrame:aRect]) {
		[self setupView];
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self setupView];
}


- (void)drawRect:(CGRect)rect {
	if (_numberOfPages == 0 || (_numberOfPages == 1 && _hidesForSinglePage)) {
		return;
	}
	UIColor *activeColor = _dotColor ? [_dotColor colorWithAlphaComponent:1] : [UIColor whiteColor];
	UIColor *inactiveColor = _dotColor ? [_dotColor colorWithAlphaComponent:kInactiveDotAlpha]
	: [UIColor colorWithWhite:1 alpha:kInactiveDotAlpha];
	CGSize dotsSize = [self sizeForNumberOfPages:_numberOfPages];
	const CGFloat left = (self.bounds.size.width - dotsSize.width) / 2;
	const CGFloat top = (self.bounds.size.height - dotsSize.height) / 2;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	for (NSInteger page = 0; page < _numberOfPages; page++) {
		(page == _displayedPage) ? [activeColor set] : [inactiveColor set];
		CGContextAddEllipseInRect(ctx, CGRectMake(left + page * (kDotSize + kDotSpacing), top, kDotSize, kDotSize));
		CGContextFillPath(ctx);
	}
}

- (void)updateCurrentPageDisplay {
	if (_displayedPage != _currentPage) {
		_displayedPage = _currentPage;
		[self setNeedsDisplay];
	}
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount {
	if (pageCount == 0 || (pageCount == 1 && _hidesForSinglePage)) {
		return CGSizeZero;
	}
	return CGSizeMake((kDotSize + kDotSpacing) * pageCount - kDotSpacing, kDotSize);
}

- (NSInteger)numberOfPages {
	return _numberOfPages;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
	if (numberOfPages < 0) {
		numberOfPages = 0;
	}
	if (_numberOfPages == numberOfPages) {
		return;
	}
	_numberOfPages = numberOfPages;
	if (_currentPage >= _numberOfPages) {
		_currentPage = _numberOfPages - 1;
	}
	if (_currentPage < 0) {
		_currentPage = 0;
	}
	if (_displayedPage >= _numberOfPages) {
		_displayedPage = _numberOfPages - 1;
	}
	if (_displayedPage < 0) {
		_displayedPage = 0;
	}
	[self setNeedsDisplay];
}

- (NSInteger)currentPage {
	return _currentPage;
}

- (void)setCurrentPage:(NSInteger)currentPage {
	if (currentPage >= _numberOfPages) {
		currentPage = _numberOfPages - 1;
	}
	if (currentPage < 0) {
		currentPage = 0;
	}
	if (_currentPage == currentPage) {
		return;
	}
	_currentPage = currentPage;
	_displayedPage = currentPage;
	[self setNeedsDisplay];
}

- (BOOL)hidesForSinglePage {
	return _hidesForSinglePage;
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
	if (_hidesForSinglePage != hidesForSinglePage) {
		return;
	}
	_hidesForSinglePage = hidesForSinglePage;
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_numberOfPages == 0 || (_numberOfPages == 1 && _hidesForSinglePage)) {
		return;
	}
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	CGSize dotsSize = [self sizeForNumberOfPages:_numberOfPages];
	const CGFloat left = (self.bounds.size.width - dotsSize.width) / 2;
	CGFloat activeDotX = left + (kDotSize + kDotSpacing) * _displayedPage + kDotSize / 2;
	BOOL updated = NO;
	if (location.x < activeDotX && _displayedPage > 0) {
		_currentPage = _displayedPage - 1;
		updated = YES;
	}
	if (location.x > activeDotX && _displayedPage < (_numberOfPages - 1)) {
		_currentPage = _displayedPage + 1;
		updated = YES;
	}
	if (updated) {
		if (!_defersCurrentPageDisplay) {
			[self updateCurrentPageDisplay];
		}
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

@end
