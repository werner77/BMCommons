//
// Created by Werner Altewischer on 13/01/17.
//

#import "NSHTTPURLResponse+BMCommons.h"
#import "NSObject+BMCommons.h"
#import "NSArray+BMCommons.h"
#import "BMCore.h"

@implementation NSHTTPURLResponse (BMCommons)

+ (NSRegularExpression *)bmContentTypeRegex {
    static NSRegularExpression *regex = nil;
    BM_DISPATCH_ONCE(^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"^.*;?\\s*charset\\s*=([^;]*);?.*$" options:NSRegularExpressionAnchorsMatchLines | NSRegularExpressionCaseInsensitive error:nil];
    });
    return regex;
}

+ (NSDictionary *)bmCharSetDictionary {
    static NSDictionary *ret = nil;
    BM_DISPATCH_ONCE((^{
        ret = @{
                @"utf-8" : @(NSUTF8StringEncoding),
                @"iso-8859-1" : @(NSISOLatin1StringEncoding),
                @"iso-8859-2" : @(NSISOLatin2StringEncoding),
                @"latin1" : @(NSISOLatin1StringEncoding),
                @"latin2" : @(NSISOLatin2StringEncoding),
                @"utf-16" : @(NSUTF16StringEncoding),
                @"us-ascii" : @(NSASCIIStringEncoding)
        };
    }));
    return ret;
}

- (NSString *)bmValueForHeader:(NSString *)header {
    NSString *ret = nil;
    if (header) {
        NSDictionary *headerFields = [self allHeaderFields];
        NSString *searchString = [header lowercaseString];
        NSString *headerKey = [[headerFields allKeys] bmFirstObjectWithPredicate:^BOOL(id key) {
            NSString *stringKey = [key bmCastSafely:NSString.class];
            return [[stringKey lowercaseString] isEqualToString:searchString];
        }];
        ret = [headerFields[headerKey] bmCastSafely:NSString.class];
    }
    return ret;
}

- (NSStringEncoding)bmContentCharacterEncoding {
    NSStringEncoding ret = 0;
    NSString *contentTypeValue = [self bmValueForHeader:@"Content-Type"];
    NSString *charSet = nil;

    if (contentTypeValue != nil) {
        NSRegularExpression *regex = [self.class bmContentTypeRegex];
        NSTextCheckingResult *result = [regex firstMatchInString:contentTypeValue options:0 range:NSMakeRange(0, contentTypeValue.length)];
        charSet = result.numberOfRanges > 1 ? [[contentTypeValue substringWithRange:[result rangeAtIndex:1]] lowercaseString] : nil;
    }

    if (charSet) {
        NSDictionary *charSetDict = [self.class bmCharSetDictionary];
        NSNumber *n = charSetDict[charSet];
        if (n != nil) {
            ret = [n unsignedIntegerValue];
        }
    }
    return ret;
}

@end