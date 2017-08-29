//
//  ICUTemplateMatcher.m
//
//  Created by Matt Gemmell on 19/05/2008.
//  Copyright 2008 Instinctive Code. All rights reserved.
//

#import <BMCommons/BMICUTemplateMatcher.h>
#import <BMCommons/BMRegexKitLite.h>

@interface BMICUTemplateMatcher()

@property(strong) NSString *markerStart;
@property(strong) NSString *markerEnd;
@property(strong) NSString *exprStart;
@property(strong) NSString *exprEnd;
@property(strong) NSString *filterDelimiter;
@property(strong) NSString *templateString;
@property(strong) NSString *regex;

@end

@implementation BMICUTemplateMatcher {
}

+ (BMICUTemplateMatcher *)matcherWithTemplateEngine:(BMMGTemplateEngine *)theEngine {
    return [[BMICUTemplateMatcher alloc] initWithTemplateEngine:theEngine];
}

- (id)init {
    return [super init];
}

- (id)initWithTemplateEngine:(BMMGTemplateEngine *)theEngine {
    if ((self = [self init])) {
        self.engine = theEngine; // weak ref
    }
    return self;
}

- (void)dealloc {
    self.engine = nil;

}

- (void)engineSettingsChanged {
    // This method is a good place to cache settings from the engine.
    self.markerStart = _engine.markerStartDelimiter;
    self.markerEnd = _engine.markerEndDelimiter;
    self.exprStart = _engine.expressionStartDelimiter;
    self.exprEnd = _engine.expressionEndDelimiter;
    self.filterDelimiter = _engine.filterDelimiter;
    self.templateString = _engine.templateContents;

    // Note: the \Q ... \E syntax causes everything inside it to be treated as literals.
    // This help us in the case where the marker/filter delimiters have special meaning
    // in regular expressions; notably the "$" character in the default marker start-delimiter.
    // Note: the (?m) syntax makes ICU enable multiline matching.
    NSString *basePattern = @"(\\Q%@\\E)(?:\\s+)?(.*?)(?:(?:\\s+)?\\Q%@\\E(?:\\s+)?(.*?))?(?:\\s+)?\\Q%@\\E";
    NSString *mrkrPattern = [NSString stringWithFormat:basePattern, self.markerStart, self.filterDelimiter, self.markerEnd];
    NSString *exprPattern = [NSString stringWithFormat:basePattern, self.exprStart, self.filterDelimiter, self.exprEnd];
    self.regex = [NSString stringWithFormat:@"(?m)(?:%@|%@)", mrkrPattern, exprPattern];
}

- (NSDictionary *)firstMarkerWithinRange:(NSRange)range {
    NSRange matchRange = [self.templateString rangeOfRegex:self.regex options:BMRegexNoOptions inRange:range capture:0 error:NULL];
    NSMutableDictionary *markerInfo = nil;
    if (matchRange.length > 0) {
        markerInfo = [NSMutableDictionary dictionary];
        [markerInfo setObject:[NSValue valueWithRange:matchRange] forKey:MARKER_RANGE_KEY];

        // Found a match. Obtain marker string.
        NSString *matchString = [self.templateString substringWithRange:matchRange];
        NSRange localRange = NSMakeRange(0, [matchString length]);
        //NSLog(@"mtch: \"%@\"", matchString);

        // Find type of match
        NSString *matchType = nil;
        NSRange mrkrSubRange = [matchString rangeOfRegex:self.regex options:BMRegexNoOptions inRange:localRange capture:1 error:NULL];
        BOOL isMarker = (mrkrSubRange.length > 0); // only matches if match has marker-delimiters
        int offset = 0;
        if (isMarker) {
            matchType = MARKER_TYPE_MARKER;
        } else {
            matchType = MARKER_TYPE_EXPRESSION;
            offset = 3;
        }
        [markerInfo setObject:matchType forKey:MARKER_TYPE_KEY];

        // Split marker string into marker-name and arguments.
        NSRange markerRange = [matchString rangeOfRegex:self.regex options:BMRegexNoOptions inRange:localRange capture:2 + offset error:NULL];

        if (markerRange.length > 0) {
            NSString *markerString = [matchString substringWithRange:markerRange];
            NSArray *markerComponents = [self argumentsFromString:markerString];
            if (markerComponents && [markerComponents count] > 0) {
                [markerInfo setObject:[markerComponents objectAtIndex:0] forKey:MARKER_NAME_KEY];
                NSUInteger count = [markerComponents count];
                if (count > 1) {
                    [markerInfo setObject:[markerComponents subarrayWithRange:NSMakeRange(1, count - 1)]
                                   forKey:MARKER_ARGUMENTS_KEY];
                }
            }

            // Check for filter.
            NSRange filterRange = [matchString rangeOfRegex:self.regex options:BMRegexNoOptions inRange:localRange capture:3 + offset error:NULL];
            if (filterRange.length > 0) {
                // Found a filter. Obtain filter string.
                NSString *filterString = [matchString substringWithRange:filterRange];

                // Convert first : plus any immediately-following whitespace into a space.
                localRange = NSMakeRange(0, [filterString length]);
                NSString *space = @" ";
                NSRange filterArgDelimRange = [filterString rangeOfRegex:@":(?:\\s+)?" options:BMRegexNoOptions inRange:localRange
                                                                 capture:0 error:NULL];
                if (filterArgDelimRange.length > 0) {
                    // Replace found text with space.
                    filterString = [NSString stringWithFormat:@"%@%@%@",
                                                              [filterString substringWithRange:NSMakeRange(0, filterArgDelimRange.location)],
                                                              space,
                                                              [filterString substringWithRange:NSMakeRange(NSMaxRange(filterArgDelimRange),
                                                                      localRange.length - NSMaxRange(filterArgDelimRange))]];
                }

                // Split into filter-name and arguments.
                NSArray *filterComponents = [self argumentsFromString:filterString];
                if (filterComponents && [filterComponents count] > 0) {
                    [markerInfo setObject:[filterComponents objectAtIndex:0] forKey:MARKER_FILTER_KEY];
                    NSUInteger count = [filterComponents count];
                    if (count > 1) {
                        [markerInfo setObject:[filterComponents subarrayWithRange:NSMakeRange(1, count - 1)]
                                       forKey:MARKER_FILTER_ARGUMENTS_KEY];
                    }
                }
            }
        }
    }

    return markerInfo;
}

- (NSArray *)argumentsFromString:(NSString *)argString {
    // Extract arguments from argString, taking care not to break single- or double-quoted arguments,
    // including those containing \-escaped quotes.
    NSString *argsPattern = @"\"(.*?)(?<!\\\\)\"|'(.*?)(?<!\\\\)'|(\\S+)";
    NSMutableArray *args = [NSMutableArray array];

    NSRegularExpression *regexPattern = [NSRegularExpression regularExpressionWithPattern:argsPattern options:0 error:nil];

    NSUInteger location = 0;
    while (location != NSNotFound) {
        NSRange searchRange = NSMakeRange(location, [argString length] - location);
        NSRange matchedRange = NSMakeRange(NSNotFound, 0);
        NSRange entireRange = NSMakeRange(NSNotFound, 0);

        NSArray *results = [regexPattern matchesInString:argString options:0 range:searchRange];

        NSTextCheckingResult *result = [results firstObject];

        if (result) {
            entireRange = [result rangeAtIndex:0];
            for (NSUInteger i = 1; i < result.numberOfRanges; ++i) {
                NSRange r = [result rangeAtIndex:i];

                if (r.location != NSNotFound) {
                    matchedRange = result.range;
                    break;
                }
            }
        }

        if (matchedRange.location != NSNotFound) {
            NSString *arg = [argString substringWithRange:matchedRange];
            [args addObject:arg];

            if (entireRange.location != NSNotFound) {
                location = NSMaxRange(entireRange) + ((entireRange.length == 0) ? 1 : 0);
            } else {
                location = NSNotFound;
            }
        } else {
            location = NSNotFound;
        }
    }

    return args;
}

@end
