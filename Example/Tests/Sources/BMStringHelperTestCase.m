//
//  BMStringHelperTestCase.m
//  BMCommons
//
//  Created by Werner Altewischer on 10/7/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMStringHelperTestCase.h"
#import <BMCommons/BMStringHelper.h>

@implementation BMStringHelperTestCase

- (void)testEncodeUrl {
    
    NSString *urlString = @"http://www.some url.com?ref=http://www.some other url.com";
    
    NSString *escapedString = [BMStringHelper urlStringFromString:urlString];
    
    NSLog(@"Escaped string: %@", escapedString);
	
    escapedString = [BMStringHelper urlStringFromString:escapedString];
    
    NSLog(@"Escaped string: %@", escapedString);
}

- (void)testRandomStringOfLength {
    NSString *s = [BMStringHelper randomStringOfLength:10 charSet:nil];

    XCTAssertEqual(10, s.length);
}

@end
