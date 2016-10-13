//
//  BMSOAPData.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/14/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Data object which is used to substitute in a SOAP request.
 */
@interface BMSOAPData : NSObject {
    @private
	NSString *username;
	NSString *password;
	NSString *body;
	NSDate *date;
	NSString *uuid;
}

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *body;

- (NSString *)dateString;
- (NSString *)uuid;

+ (BMSOAPData *)soapDataWithUsername:(NSString *)theUsername password:(NSString *)thePassword body:(NSString *)theBody;

@end
