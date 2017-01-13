//
//  BMTestCase.h
//  BMCommons
//
//  Created by Werner Altewischer on 13/01/17.
//  Copyright © 2017 Werner Altewischer. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface BMTestCase : XCTestCase

+ (NSBundle *)testBundle;
- (NSData *)dataForResource:(NSString *)resourceName ofType:(NSString *)resourceType;


@end
