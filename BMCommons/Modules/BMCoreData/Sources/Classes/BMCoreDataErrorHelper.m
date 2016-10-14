//
//  BMCoreDataErrorHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/16/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCoreDataErrorHelper.h>
#import <CoreData/CoreData.h>

@implementation BMCoreDataErrorHelper

+ (NSError *)validationErrorFromOriginalError:(NSError *)originalError error:(NSError *)secondError {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSMutableArray *errors = [NSMutableArray arrayWithObject:secondError];
    
    if ([originalError code] == NSValidationMultipleErrorsError) {
        
        [userInfo addEntriesFromDictionary:[originalError userInfo]];
        [errors addObjectsFromArray:userInfo[NSDetailedErrorsKey]];
    }
    else {
        [errors addObject:originalError];
    }
    
    userInfo[NSDetailedErrorsKey] = errors;
    return [NSError errorWithDomain:NSCocoaErrorDomain
                               code:NSValidationMultipleErrorsError
                           userInfo:userInfo];
}


@end
