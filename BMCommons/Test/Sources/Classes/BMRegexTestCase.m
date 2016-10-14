//
//  BMRegexTestCase.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/17/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMRegexTestCase.h"
#import <BMCommons/BMRegexKitLite.h>

#define EMAIL_VALIDATION_REGEXP @"^(\\w[-._\\w]*@\\w[-._\\w]*\\w\\.\\w{2,6})$"

@implementation BMRegexTestCase

- (void)setUp {
}

- (void)tearDown {
}

- (void)testEmailValidation{
	
	NSString *regExpr = EMAIL_VALIDATION_REGEXP;
	
	BOOL valid = ([@"edwin(at)mirabeau.nl" stringByMatching:regExpr] != nil);
	GHAssertFalse(valid, @"Expected validation to fail for email without @ sign");

	valid = ([@"edwin@mirabeau(dot)nl" stringByMatching:regExpr] != nil);
	GHAssertFalse(valid, @"Expected validation to fail for email without . sign");

	valid = ([@"edwin@.mirabeau.nl" stringByMatching:regExpr] != nil);
	GHAssertFalse(valid, @"Expected validation to fail for email without characters between @ and .");

	valid = ([@"edwin@mirabeau.nl" stringByMatching:regExpr] != nil);
	GHAssertTrue(valid, @"Expected validation to succeed for normal email");

	valid = ([@"edwin.vermeer@mirabeau.nl" stringByMatching:regExpr] != nil);
	GHAssertTrue(valid, @"Expected validation to succeed for normal email with a . before the @");

	valid = ([@"edwin.vermeer@iphone.mirabeau.nl" stringByMatching:regExpr] != nil);
	GHAssertTrue(valid, @"Expected validation to succeed for normal email with multiple .");
	
}

@end
