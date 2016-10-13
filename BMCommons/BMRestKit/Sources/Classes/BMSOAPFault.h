//
//  BMSOAPFault.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/14/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMRestKit/BMAbstractMappableObject.h>

/**
 Object which is mapped from a SOAP fault response.
 */
@interface BMSOAPFault : BMAbstractMappableObject {
    @private
	NSString *faultCode;
	NSString *faultString;
}

@property (nonatomic, strong) NSString *faultCode;
@property (nonatomic, strong) NSString *faultString;

- (NSError *)error;

@end
