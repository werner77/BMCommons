//
//  BMTableHeaderDragRefreshView.h
//  BMCommons
//
//  Created by Werner Altewischer.
//  Copyright 2011 BehindMedia. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <BMUICore/BMStyleSheet.h>

typedef NS_ENUM(NSUInteger, BMTableHeaderDragRefreshStatus) {
    BMTableHeaderDragRefreshReleaseToReload,
    BMTableHeaderDragRefreshPullToReload,
    BMTableHeaderDragRefreshLoading
};

/**
 View which is used by BMTableViewController for drag to refresh functionality.
 */
@interface BMTableHeaderDragRefreshView : UIView

- (void)setCurrentDate;

/**
 Sets the update date which is shown.
 */
- (void)setUpdateDate:(NSDate*)date;

/**
 Sets the status.
 */
- (void)setStatus:(BMTableHeaderDragRefreshStatus)status;
- (BMTableHeaderDragRefreshStatus)status;

/**
 Applies the specified stylesheet to this view.
 */
- (void)applyStyleSheet:(BMStyleSheet*)styleSheet;

@end