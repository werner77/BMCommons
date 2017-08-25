//
//  NSArray_DeepMutableCopy.h
//
//  Created by Matt Gemmell on 02/05/2008.
//  Copyright 2008 Instinctive Code. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (DeepMutableCopy)

- (NSMutableArray *)bmDeepMutableCopy;

@end

NS_ASSUME_NONNULL_END
