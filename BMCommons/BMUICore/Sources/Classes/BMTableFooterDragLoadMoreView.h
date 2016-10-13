//
//  BMTableFooterDragLoadMoreView.h
//  BMCommons
//
//  Created by Werner Altewischer on 21/07/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMUICore/BMStyleSheet.h>

typedef NS_ENUM(NSUInteger, BMTableFooterDragLoadMoreStatus) {
    BMTableFooterDragLoadMoreNone = 0,
    BMTableFooterDragLoadMoreReleaseToLoad = 1,
    BMTableFooterDragLoadMorePullToLoad = 2,
    BMTableFooterDragLoadMoreLoading = 3,
    BMTableFooterDragLoadMoreNothingMoreToLoad = 4
};

/**
 The footer view used by BMTableViewController for drag to load more functionality.
 */
@interface BMTableFooterDragLoadMoreView : UIView

/**
 Set to override the default name displayed for a single item as 'photo' in:
 
 1 photo shown.
 
 The default is loaded from the strings resources under key dragloadmoreview.text.item.
 */
@property (nonatomic, strong) NSString *itemName;

/**
 Set to override the default name displayed for multiple items as 'photos' in:
 
 2 photos shown.
 
 The default is loaded from the strings resources under key dragloadmoreview.text.items.
 */
@property (nonatomic, strong) NSString *itemsName;

/**
 Sets the loaded and total count to be displayed.
 */
- (void)setLoadedCount:(NSUInteger)loadedCount withTotalCount:(NSUInteger)totalCount;
- (void)setStatus:(BMTableFooterDragLoadMoreStatus)status;
- (BMTableFooterDragLoadMoreStatus)status;

/**
 Applies a style sheet to this view (overriding the default).
 */
- (void)applyStyleSheet:(BMStyleSheet*)styleSheet;

@end