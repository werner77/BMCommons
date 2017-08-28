/*
 *  BMClickable.h
 *  BehindMedia
 *
 *  Created by Werner Altewischer on 26/10/09.
 *  Copyright 2010 BehindMedia. All rights reserved.
 *
 */

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol describing a clickable or tappable object/view.
 */
@protocol BMClickable

/**
 Handles the click event.
 */
- (void)onClick;

/**
 Returns true iff click is enabled.
 */
- (BOOL)clickEnabled;

/**
 Sets click enabled state.
 */
- (void)setClickEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END