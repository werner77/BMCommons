//
//  NSURL+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 3/6/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "NSURL+BMCommons.h"
#import "NSDictionary+BMCommons.h"
#import <BMCommons/BMStringHelper.h>

@implementation NSURL (BMCommons)

- (NSURL *)bmURLByAppendingQueryParams:(NSDictionary *)queryParams {
    if (queryParams.count == 0) {
        return self;
    }

    NSString *absoluteString = [self absoluteString];

    if (absoluteString != nil) {
        NSString *queryString = [BMStringHelper queryStringFromParameters:queryParams includeQuestionMark:NO];
        NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", absoluteString,
                                                               [self query] ? @"&" : @"?", queryString];
        return [NSURL URLWithString:URLString];
    } else {
        return nil;
    }
}

- (NSURL *)bmURLByUpdatingQueryParams:(NSDictionary *)queryParams {
    if (queryParams.count == 0) {
        return self;
    }

    NSMutableDictionary *parameterDict = [NSMutableDictionary dictionaryWithDictionary:[BMStringHelper parametersFromQueryString:[self query] decodePlusSignsAsSpace:NO]];
    for (id key in queryParams) {
        id value = queryParams[key];
        if (value == [NSNull null]) {
            [parameterDict removeObjectForKey:key];
        } else {
            [parameterDict bmSafeSetObject:value forKey:key];
        }
    }
    return [self bmURLWithQueryParams:parameterDict];
}

- (NSURL *)bmURLByRemovingQueryParams:(NSArray *)queryParamNames {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    for (NSString *paramName in queryParamNames) {
        [dict bmSafeSetObject:[NSNull null] forKey:paramName];
    }
    return [self bmURLByUpdatingQueryParams:dict];
}

- (NSURL *)bmURLWithQueryParams:(NSDictionary *)parameterDict {
    NSString *baseUrlString = [self bmURLStringByRemovingQuery];
    NSString *queryString = [BMStringHelper queryStringFromParameters:parameterDict includeQuestionMark:YES];
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@", baseUrlString, [BMStringHelper filterNilString:queryString]];
    return [NSURL URLWithString:URLString];
}

- (NSURL *)bmURLByRemovingQuery {
    NSString *urlString = [self absoluteString];
    NSURL *ret = self;
    NSRange range = [urlString rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        urlString = [urlString substringToIndex:range.location];
        ret = [NSURL URLWithString:urlString];
    }
    return ret;
}

- (NSString *)bmURLStringByRemovingQuery {
    NSString *urlString = [self absoluteString];
    NSRange range = [urlString rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        urlString = [urlString substringToIndex:range.location];
    }
    return urlString;
}

@end
