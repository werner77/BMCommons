//
//  BMKeyValuePair.h
//  BMCommons
//
//  Created by Werner Altewischer on 1/13/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMKeyValuePair : NSObject

@property (nullable, nonatomic, strong) NSString *key;
@property (nullable, nonatomic, strong) id value;

@end

NS_ASSUME_NONNULL_END
