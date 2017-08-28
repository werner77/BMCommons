//
//  BMAction.h
//  BMCommons
//
//  Created by Werner Altewischer on 1/4/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Class that encapsulates a target/selector combination.
 */
@interface BMAction : BMCoreObject

/**
 * The target to execute the selector on.
 */
@property (nonatomic, weak) id target;

/**
 * The selector to execute.
 */
@property (nonatomic, assign) SEL selector;

@end

NS_ASSUME_NONNULL_END