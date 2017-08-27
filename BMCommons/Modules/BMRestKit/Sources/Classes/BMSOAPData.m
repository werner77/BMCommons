//
//  BMSOAPData.m
//  BMCommons
//
//  Created by Werner Altewischer on 7/14/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMSOAPData.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMDateHelper.h>
#import <BMCommons/BMRestKit.h>

@implementation BMSOAPData {
@private
	NSString *username;
	NSString *password;
	NSString *body;
	NSDate *date;
	NSString *uuid;
}

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
