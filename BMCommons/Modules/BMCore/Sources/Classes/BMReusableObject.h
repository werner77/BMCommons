/*
 *  BMCommonsReusableObject.h
 *  BMCommons
 *
 *  Created by Werner Altewischer on 21/10/10.
 *  Copyright 2010 BehindMedia. All rights reserved.
 *
 */

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol to be implemented for objects that can be reused, such as views, compare with UITableViewCell
 */
@protocol BMReusableObject<NSObject>

/**
 The reuse identifier for the object.
 
 @see [BMReusableObjectContainer dequeueReusableObjectWithIdentifier:]
 */
- (NSString *)reuseIdentifier;

/**
 Prepares the object for reuse by clearing any superfluous internal state.
 */
- (void)prepareForReuse;

@end

/**
 Container for BMReusableObject instances which supports dequeuing.
 
 Compare with UITableView and dequeueReusableCellWithIndentifier:
 This is a generalization for any view or object.
 */
@protocol BMReusableObjectContainer <NSObject>

/**
 Dequeus a reusable object with the specified identifier.
 
 @see [BMReusableObject reuseIdentifier]
 */
- (nullable id <BMReusableObject>)dequeueReusableObjectWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END