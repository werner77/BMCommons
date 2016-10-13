//
//  ICUTemplateMatcher.h
//
//  Created by Matt Gemmell on 19/05/2008.
//  Copyright 2008 Instinctive Code. All rights reserved.
//

#import "BMMGTemplateEngine.h"

/**
 Example Matcher for BMMGTemplateEngine.
 
 This is an example Matcher for BMMGTemplateEngine, implemented using libicucore on Leopard,
 via the RegexKitLite library: http://regexkit.sourceforge.net/#RegexKitLite
 
 This project includes everything you need, as long as you're building on Mac OS X 10.5 or later.
 
 Other matchers can easily be implemented using the BMMGTemplateEngineMatcher protocol,
 if you prefer to use another regex framework, or use another matching method entirely.
 */
@interface BMICUTemplateMatcher : NSObject <BMMGTemplateEngineMatcher> {
	BMMGTemplateEngine *__weak engine;
	NSString *markerStart;
	NSString *markerEnd;
	NSString *exprStart;
	NSString *exprEnd;
	NSString *filterDelimiter;
	NSString *templateString;
	NSString *regex;
}

@property(weak) BMMGTemplateEngine *engine; // weak ref
@property(strong) NSString *markerStart;
@property(strong) NSString *markerEnd;
@property(strong) NSString *exprStart;
@property(strong) NSString *exprEnd;
@property(strong) NSString *filterDelimiter;
@property(strong) NSString *templateString;
@property(strong) NSString *regex;

+ (BMICUTemplateMatcher *)matcherWithTemplateEngine:(BMMGTemplateEngine *)theEngine;

- (NSArray *)argumentsFromString:(NSString *)argString;

@end
