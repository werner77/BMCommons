//
//  BMCoreDataErrorHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/16/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMCoreDataErrorHelper : NSObject

+ (NSError *)validationErrorFromOriginalError:(NSError *)originalError error:(NSError *)secondError;

@end
