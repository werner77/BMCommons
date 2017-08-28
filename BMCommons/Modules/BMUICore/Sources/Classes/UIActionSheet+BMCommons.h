//
//  UIActionSheet+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 13/09/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Adds a context to an actionsheet.
 */
@interface UIActionSheet(BMCommons)

/**
 The context. 
 
 Set it to nil when done with the actionsheet to avoid a memory leak.
 */
@property (nullable, nonatomic, strong) id bmContext;

@end

NS_ASSUME_NONNULL_END
