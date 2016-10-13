//
//  BMSOAPData.m
//  BMCommons
//
//  Created by Werner Altewischer on 7/14/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMSOAPData.h"
#import <BMCore/BMStringHelper.h>
#import <BMCore/BMDateHelper.h>
#import <BMRestKit/BMRestKit.h>

@implementation BMSOAPData

@synthesize username;
@synthesize password;
@synthesize body;

+ (BMSOAPData *)soapDataWithUsername:(NSString *)theUsername password:(NSString *)thePassword body:(NSString *)theBody {
	BMSOAPData *data = [BMSOAPData new];
	data.username = theUsername;
	data.password = thePassword;
	data.body = theBody;
	return data;
}

- (id)init {
	if ((self = [super init])) {
        BMRestKitCheckLicense();
		date = [NSDate date];
		uuid = [BMStringHelper stringWithUUID];
	}
	return self;
}

- (NSString *)uuid {
	return uuid;
}

- (NSString *)dateString {
	NSDateFormatter *df = [BMDateHelper rfc3339TimestampFractionalFormatterWithTimeZone];
	return [df stringFromDate:date];
}


@end
