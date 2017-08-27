//
//  BMSOAPFault.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/14/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMAbstractMappableObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Object which is mapped from a SOAP fault response.
 */
@interface BMSOAPFault : BMAbstractMappableObject

@property (nullable, nonatomic, strong) NSString *faultCode;
@property (nullable, nonatomic, strong) NSString *faultString;

- (NSError *)error;

@end

NS_ASSUME_NONNULL_END
