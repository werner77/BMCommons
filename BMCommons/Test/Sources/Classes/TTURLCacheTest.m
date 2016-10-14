//
//  TTURLCacheTest.m
//  BMCommons
//
//  Created by Werner Altewischer on 4/26/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "TTURLCacheTest.h"
#import <BMCommons/BMURLCache.h>

@implementation TTURLCacheTest

- (void)testCacheExpiration {
	
	BMURLCache *cache = [BMURLCache sharedCache];
	
	//Set expiration to 1 second
	cache.invalidationAge = 1.0;
	
	
	NSString *dataString = @"blabla";
	NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
	NSString *url = @"http://somehost.com/somepath";
	
	[cache storeData:data forURL:url];
	
	GHAssertNotNil([cache dataForURL:url], nil, nil);
	
	[cache pinDataForURL:url];
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0 * cache.invalidationAge]];
	
	GHAssertNotNil([cache dataForURL:url], nil, nil);
	
	[cache unpinDataForURL:url];
	
	GHAssertNil([cache dataForURL:url], nil, nil);
	

	[cache storeData:data forURL:url];
	[cache pinDataForURL:url];
	
	//Should be able to overwrite data, even when pinned
	[cache storeData:data forURL:url];
	
	[cache removeAll:YES];
	
	GHAssertNil([cache dataForURL:url], nil, nil);
}

@end
