//
//  BMKeyValuePair.h
//  BMCommons
//
//  Created by Werner Altewischer on 1/13/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMDynamicObject : NSObject

@property (nonatomic, strong, readonly) NSDictionary *fieldDictionary;

@end

NS_ASSUME_NONNULL_END