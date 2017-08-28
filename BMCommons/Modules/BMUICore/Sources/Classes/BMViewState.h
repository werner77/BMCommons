//
//  BMViewState.h
//  BMCommons
//
//  Created by Werner Altewischer on 20/11/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 Enum that describes the visibility state of the view.
 
 BMViewStateInvisible: after viewDidDisappear and before viewWillAppear
 BMViewStateToBecomeVisible: after viewWillAppear and before viewDidAppear
 BMViewStateVisible: after viewDidAppear.
 BMViewStateToBecomeInvisible: after viewWillDisappear and before viewDidDisappear
 
 */
typedef enum BMViewState {
    BMViewStateInvisible = 0,
    BMViewStateToBecomeVisible = 1,
    BMViewStateVisible = 2,
    BMViewStateToBecomeInvisible = 3,
} BMViewState;

NS_ASSUME_NONNULL_END