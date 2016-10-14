//
//  BMPageControl.h
//  BMCommons
//
//  Created by Werner Altewischer on 04/11/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Custom UIPageControl with support for custom dot color.
 */
@interface BMPageControl : UIControl 

/**
 The number of pages/dots to display.
 
 Default is 0.
 */
@property(nonatomic) NSInteger numberOfPages;

/**
 The index for the current page/highlighted dot.
 
 Default is 0. Value should be less than numberOfPages.
 */
@property(nonatomic) NSInteger currentPage;

/**
 Whether to hide when there's only one page available.
 
 Default is NO.
 */
@property(nonatomic) BOOL hidesForSinglePage;

/**
 If set to YES changing pages via a touch won't immediately update the highlighted dot. 
 
 The dots are updated when updateCurrentPageDisplay is called afterwards.
 
 Default is NO.
 */
@property(nonatomic) BOOL defersCurrentPageDisplay;

/**
 The color to use for the dots.
 
 Defaults to [UIColor whiteColor].
 */
@property(nonatomic, strong) UIColor *dotColor;

/**
 Updates the page display (highlighted dot) to match the current page.
 
 Is called automatically if defersCurrentPageDisplay is NO.
 */
- (void)updateCurrentPageDisplay;

@end

@interface BMPageControl(Protected)

/**
 Returns the minimum size required to display dots for given page count.
 
 Can be overridden to size the control accordingly.
 */
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;

@end
