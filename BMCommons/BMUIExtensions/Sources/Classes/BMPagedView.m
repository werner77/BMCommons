//
//  BMPagedView.m
//  BMCommons
//
//  Created by Werner Altewischer on 21/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMPagedView.h>
#import <BMCommons/BMPageControl.h>
#import <BMCommons/BMUICore.h>

@interface BMPagedView()<UIScrollViewDelegate>

@end

@interface BMPagedView (Private)

- (NSUInteger)pageCount;

- (UIView *)loadViewForIndex:(NSUInteger)pageIndex;
- (void)unloadViewForIndex:(NSUInteger)pageIndex;
- (void)loadViewsForVisiblePages:(BOOL)reloadData;	
- (UIView *)viewForIndex:(NSUInteger)pageIndex;
- (void)setupScrollView;
- (NSUInteger)indexForCurrentContentOffset;
- (CGFloat)contentOffsetForIndex:(NSUInteger)index;
- (NSUInteger)indexForContentOffset:(CGFloat)cx;
- (void)scrollToSelectedPage;

- (void)willChangeSelectionToPage:(NSUInteger)page;
- (void)didChangeSelection;

@end

@implementation BMPagedView {
    UIScrollView *_scrollView;
    BMPageControl *_pageControl;
    NSMutableDictionary *_pageViewDictionary;
    NSMutableDictionary *_reuseViewDictionary;

    id <BMPagedViewDelegate> __weak _delegate;
    NSInteger _indexForSelectedPage;
    NSInteger _oldPageIndex;
    NSTimer *_updateViewsTimer;
    CGFloat _pageVerticalOffset;
    CGRect _pageFrame;
    CGFloat _pageSpacing;
}

@synthesize delegate = _delegate, scrollView = _scrollView, pageControl = _pageControl, pageFrame = _pageFrame, pageSpacing = _pageSpacing;

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super initWithCoder:coder])) {
        _pageFrame = CGRectZero;
        _oldPageIndex = -1;
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _pageFrame = CGRectZero;
        _oldPageIndex = -1;
        [self setupScrollView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupScrollView];
}

- (void)dealloc {
    _scrollView.delegate = nil;
	[_updateViewsTimer invalidate];
	BM_RELEASE_SAFELY(_updateViewsTimer);
	BM_RELEASE_SAFELY(_pageViewDictionary);
	BM_RELEASE_SAFELY(_reuseViewDictionary);
	BM_RELEASE_SAFELY(_scrollView);
	BM_RELEASE_SAFELY(_pageControl);
}

- (CGRect)pageFrame {
    if (CGRectEqualToRect(CGRectZero, _pageFrame)) {
        return CGRectMake(0, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
    } else {
        return _pageFrame;
    }
}

- (void)reloadDataForSelectedPage {
	if (!_pageViewDictionary) {
		//Cannot reload data for this page if not initialized yet
		[self reloadData];
	} else {
		NSInteger i = self.indexForSelectedPage;
		[self unloadViewForIndex:i];
		[self loadViewForIndex:i];
		[_reuseViewDictionary removeAllObjects];
	}
}

- (void)reloadData {
	if (!_pageViewDictionary) {
		//First time initialization	
		_pageViewDictionary = [NSMutableDictionary new];
		_reuseViewDictionary = [NSMutableDictionary new];
		[_pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
		_scrollView.delegate = self;
        _scrollView.pagingEnabled = NO;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
	}
	
	CGFloat height = _scrollView.frame.size.height;
	
	NSUInteger numberOfPages = self.pageCount;	
	_pageControl.numberOfPages = MAX(1, numberOfPages);
    
    CGFloat width = [self contentOffsetForIndex:numberOfPages];
    if (numberOfPages > 0) {
        width -=  self.pageSpacing;
    }
	[_scrollView setContentSize:CGSizeMake(width, height)];
	_pageControl.currentPage = self.indexForSelectedPage;
	
	_pageControl.hidden = (numberOfPages == 0);
    
    [_scrollView setContentOffset:CGPointMake([self contentOffsetForIndex:self.indexForSelectedPage], _scrollView.contentOffset.y)];
	
	[self loadViewsForVisiblePages:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
	[self reloadData];
}

- (void)scrollToPageAtIndex:(NSUInteger)pageIndex animated:(BOOL)animated {
	if (pageIndex < self.pageCount) {
		CGSize size = _scrollView.frame.size;
		CGRect rect = CGRectMake([self contentOffsetForIndex:pageIndex], 0, size.width, size.height);
        
        BOOL pageChange = pageIndex != _indexForSelectedPage;
        
        if (pageChange) [self willChangeSelectionToPage:pageIndex];
		[_scrollView scrollRectToVisible:rect animated:animated];
        if (pageChange) {
            //Call didChangeSelection in the next runloop because it loads views and could be blocking
            CGFloat delay = 0.0;
            if (animated) {
                delay = 0.3;
            }
            [self performSelector:@selector(didChangeSelection) withObject:nil afterDelay:delay];
        }
        
	}
}

- (NSInteger)indexForSelectedPage {
	return _indexForSelectedPage;
}

- (UIView *)viewForPageAtIndex:(NSUInteger)pageIndex {
	return [self viewForIndex:pageIndex];
}

- (UIView *)viewForSelectedPage {
	return [self viewForPageAtIndex:self.indexForSelectedPage];
}

#pragma mark -
#pragma mark UIScrollViewDelegate implementation

- (void)scrollViewWillBeginDragging:(UIScrollView *)theScrollView {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)theScrollView {

}

- (void) scrollViewWillEndDragging:(UIScrollView *)scroll withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    static const CGFloat kThresholdFactor = 0.1;
    
    *targetContentOffset = scroll.contentOffset;
    
    CGFloat currentOffset = [self contentOffsetForIndex:_indexForSelectedPage];
    
    CGFloat nextOffset = currentOffset;
    NSUInteger nextPageIndex = _indexForSelectedPage;
    
    if (scroll.contentOffset.x > currentOffset && _indexForSelectedPage < self.pageCount - 1) {
        nextPageIndex = _indexForSelectedPage + 1;
        nextOffset = [self contentOffsetForIndex:nextPageIndex];
    } else if (scroll.contentOffset.x < currentOffset && _indexForSelectedPage > 0) {
        nextPageIndex = _indexForSelectedPage - 1;
        nextOffset = [self contentOffsetForIndex:nextPageIndex];
    }
    
    if (nextPageIndex != _indexForSelectedPage) {
        CGFloat factor = (scroll.contentOffset.x - currentOffset) / (nextOffset - currentOffset);
        
        if (factor > kThresholdFactor) {
            [self scrollToPageAtIndex:nextPageIndex animated:YES];
            return;
        }
    }
    
    [self scrollToSelectedPage];
}

-(void)scrollViewDidScroll:(UIScrollView *)theScrollView {
   
}

- (void)pageChanged:(BMPageControl *)thePageControl {
	if (_pageControl == thePageControl) {
		[self scrollToPageAtIndex:_pageControl.currentPage animated:YES];
	}
}

- (UIView<BMReusableObject> *)dequeueReusableViewWithIdentifier:(NSString *)identifier {
	UIView<BMReusableObject> *v = _reuseViewDictionary[identifier];
	if (v) {
		[v prepareForReuse];
		[_reuseViewDictionary removeObjectForKey:identifier];
	}
	return v;
}

- (id<BMReusableObject> )dequeueReusableObjectWithIdentifier:(NSString *)identifier {
    return [self dequeueReusableViewWithIdentifier:identifier];
}

@end


@implementation BMPagedView (Private)

- (NSUInteger)indexForContentOffset:(CGFloat)cx {
    NSUInteger index = (NSUInteger)(0.5 + cx / (_scrollView.frame.size.width + self.pageSpacing));
	if (index >= self.pageCount) {
		index = NSNotFound;
	}
    return index;
}

- (NSUInteger)indexForCurrentContentOffset {
    CGFloat cx = _scrollView.contentOffset.x;
    
    return [self indexForContentOffset:cx];
}

- (CGFloat)contentOffsetForIndex:(NSUInteger)index {
    return index * (_scrollView.frame.size.width + self.pageSpacing);
}

- (NSUInteger)pageCount {
	return [self.delegate numberOfPagesInPagedView:self];
}

- (UIView *)viewForIndex:(NSUInteger)pageIndex {
	id key = @(pageIndex);
	return _pageViewDictionary[key];
}

- (UIView *)loadViewForIndex:(NSUInteger)pageIndex {
	id key = @(pageIndex);
	UIView *v = _pageViewDictionary[key];
	if (!v) {
        CGRect pf = self.pageFrame;
        if ([self.delegate respondsToSelector:@selector(pagedView:frameForPageAtIndex:)]) {
            pf = [self.delegate pagedView:self frameForPageAtIndex:pageIndex];
        }
        
		UIView *v = [self.delegate pagedView:self viewForPageAtIndex:pageIndex];
		if (v) {
			v.frame = CGRectMake([self contentOffsetForIndex:pageIndex] + pf.origin.x, pf.origin.y, pf.size.width, pf.size.height);
			[_scrollView addSubview:v];
			_pageViewDictionary[key] = v;
		}
	} 
	return v;
}

- (void)unloadViewForIndex:(NSUInteger)pageIndex {
	id key = @(pageIndex);
	UIView *v = _pageViewDictionary[key];
	if (v) {
		if ([v conformsToProtocol:@protocol(BMReusableObject)]) {
			NSString *reuseIdentifier = [(id <BMReusableObject>)v reuseIdentifier];
			_reuseViewDictionary[reuseIdentifier] = v;
		}
		[v removeFromSuperview];
		[_pageViewDictionary removeObjectForKey:key];
	}
	
}

- (void)willChangeSelectionToPage:(NSUInteger)page {
    if ([self.delegate respondsToSelector:@selector(pagedView:willChangeSelectionFromIndex:toIndex:)]) {
        [self.delegate pagedView:self willChangeSelectionFromIndex:_indexForSelectedPage toIndex:page];
    }
    _oldPageIndex = _indexForSelectedPage;
    _indexForSelectedPage = page;
}

- (void)didChangeSelection {
    if (_oldPageIndex >= 0) {
        _pageControl.currentPage = _indexForSelectedPage;
        [self loadViewsForVisiblePages:NO];
        if ([self.delegate respondsToSelector:@selector(pagedView:didChangeSelectionFromIndex:toIndex:)]) {
            [self.delegate pagedView:self didChangeSelectionFromIndex:_oldPageIndex toIndex:_indexForSelectedPage];
        }
        _oldPageIndex = -1;
    }
}

- (void)loadViewsForVisiblePages:(BOOL)reloadData {
	
	//load the selected view and the one in front and behind
	
	NSUInteger selectedPage = self.indexForSelectedPage;
	NSUInteger numberOfPages = self.pageCount;
	
	int intSelectedPage = (selectedPage == NSNotFound) ? -2 : (int)selectedPage;
	
	//Find the max number present in the pageViewDictionary
	NSUInteger existingPageCount = 0;
	for (NSNumber *key in _pageViewDictionary) {
		if ([key unsignedIntegerValue] >= existingPageCount) {
			existingPageCount = [key unsignedIntegerValue] + 1;
		}
	}
	
	for (int i = 0; i < MAX(numberOfPages, existingPageCount); ++i) {
		if (i >= numberOfPages || 
			i < (intSelectedPage - 1) ||
			i > (intSelectedPage + 1)) {
			[self unloadViewForIndex:i];
		} else {
			if (reloadData) {
				//Unload the view if we're reloading all the data
				[self unloadViewForIndex:i];
			}
			[self loadViewForIndex:i];
		}
	}
	
	[_reuseViewDictionary removeAllObjects];
}

- (void)setupScrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
    }
}

- (void)scrollToSelectedPage {
    [self scrollToPageAtIndex:self.indexForSelectedPage animated:YES];
}

@end
