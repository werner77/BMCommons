//
//  BMBase64DataTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 06/08/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMBase64DataTransformer : NSValueTransformer

@property (nonatomic, assign) BOOL urlFriendlyMode;

@end

NS_ASSUME_NONNULL_END