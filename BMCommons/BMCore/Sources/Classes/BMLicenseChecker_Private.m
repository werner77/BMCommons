//
//  BMLicenseChecker_Private.m
//  BMCommons
//
//  Created by Werner Altewischer on 7/23/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMLicenseChecker_Private.h"
#import "NSString+BMCommons.h"
#import "BMStringHelper.h"
#import "BMLogging.h"
#import "NSData+BMEncryption.h"
#import "BMEncodingHelper.h"
#import "BMCache.h"

#define FIELD_CONTENT_TYPE @"Content-Type"
#define FIELD_CONTENT_ENCODING @"Content-Encoding"
#define FIELD_CONTENT_LENGTH @"Content-Length"
#define FIELD_AUTHORIZATION @"Authorization"

#define BASIC_USER_NAME @"uJtVhCJF2HRrUbHV"
#define BASIC_PASSWORD @"nP4veTNr6ecVSHGA"

@interface BMLicenseChecker()

@end

static BMLicenseChecker *sInstance = nil;

@implementation BMLicenseChecker

- (id)init {
    if ((self = [super init])) {
        _queue = [NSOperationQueue new];
        _queue.maxConcurrentOperationCount = 1;
        _blocksToCall = [NSMutableDictionary new];
    }
    return self;
}

+ (id)instance {
    if (!sInstance) {
        sInstance = [self new];
    }
    return sInstance;
}


- (void)checkLicense:(NSString *)license forApp:(NSString *)appId module:(NSString *)moduleIdentifier publicKey:(SecKeyRef)publicKey completionBlock:(BMLicenseCheckerBlock)block {
    NSURL *licenseServerURL = [NSURL URLWithString:@"https://license.behindmedia.com/service/validateLicense"];
    if (license && appId) {
        NSDictionary *params = @{@"licenseKey" : license, @"appId" : appId};
        [self postToURL:licenseServerURL withParameters:params publicKey:(SecKeyRef)publicKey completionBlock:block];
    } else {
        block(NO);
    }
}

#pragma mark - Private

- (NSString *)queryStringForParameters:(NSDictionary *)theParameters {
    NSMutableString *queryString = [NSMutableString string];
    BOOL first = YES;
    for (NSString *key in theParameters) {
        id p = [theParameters objectForKey:key];
        if (p == nil || p == [NSNull null]) continue;
        if (first) {
            first = NO;
        } else {
            [queryString appendString:@"&"];
        }
        NSString *parameter = [p isKindOfClass:[NSString class]] ? p : [p description];
        NSString *escapedKey = [key bmStringWithPercentEscapes];
        NSString *escapedValue = [parameter bmStringWithPercentEscapes];
        [queryString appendFormat:@"%@=%@", escapedKey, escapedValue];
    }
    return queryString;
}

- (void)postToURL:(NSURL *)url withParameters:(NSDictionary *)parameters publicKey:(SecKeyRef)publicKey completionBlock:(BMLicenseCheckerBlock)block {

    NSString *queryString = [self queryStringForParameters:parameters];
    NSMutableArray *blocksToCall = [_blocksToCall objectForKey:queryString];
    
    if (!blocksToCall) {
        blocksToCall = [NSMutableArray arrayWithObject:[block copy]];
        [_blocksToCall setObject:blocksToCall forKey:queryString];
    } else {
        [blocksToCall addObject:[block copy]];
        return;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    NSData *content = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:FIELD_CONTENT_TYPE];

    NSString *encodedCredentials = [self encodeUserName:BASIC_USER_NAME andPassword:BASIC_PASSWORD];
    NSString *authorizationHeader = [NSString stringWithFormat:@"Basic %@", encodedCredentials];
    [request addValue:authorizationHeader forHTTPHeaderField:FIELD_AUTHORIZATION];
    [request addValue:[NSString stringWithFormat:@"%d", (int)content.length] forHTTPHeaderField:FIELD_CONTENT_LENGTH];
    [request setHTTPBody:content];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:_queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               //Default to valid, because we don't want to bother when no network is available, we'll just try the next time.
                               BOOL validLicense = YES;
                               if (error) {
                                   LogDebug(@"License check failed with error: %@", error);
                               } else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if (httpResponse.statusCode == 200) {
                                       validLicense = [self validateLicenseResponse:data withPublicKey:publicKey];
                                   } else {
                                       LogDebug(@"No successful HTTP response from license check, response was: %d", (int)httpResponse.statusCode);
                                       LogDebug(@"Response:\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   }
                               }
     
                               NSMutableArray *finishedBlocksToCall = [_blocksToCall objectForKey:queryString];
                               for (BMLicenseCheckerBlock b in finishedBlocksToCall) {
                                   b(validLicense);
                               }
                               [_blocksToCall removeObjectForKey:queryString];
                           }];
}

- (NSString *)decryptedReponseFromData:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (BOOL)validateLicenseResponse:(NSData *)data withPublicKey:(SecKeyRef)publicKey {
    //Decrypt the message
    NSString *decryptedResponse = [self decryptedReponseFromData:data];
    
    NSRange range = [decryptedResponse rangeOfString:@"&hash="];
    
    NSString *baseString = nil;
    
    if (range.location != NSNotFound) {
        baseString = [decryptedResponse substringWithRange:NSMakeRange(0, range.location)];
    }
    
    NSDictionary *dict = [BMStringHelper parametersFromQueryString:decryptedResponse decodePlusSignsAsSpace:NO];
    
    NSString *hash = [dict objectForKey:@"hash"];
    NSString *validString = [dict objectForKey:@"valid"];
    
    NSData *hashData = [BMEncodingHelper dataWithBase64EncodedString:hash];
    
    BOOL validSignature = [[baseString dataUsingEncoding:NSUTF8StringEncoding] bmVerifySignature:hashData withKey:publicKey];
    
    return [validString boolValue] && validSignature;
}

- (NSString *)encodeUserName:(NSString *)theUserName andPassword:(NSString *)thePassword {
    NSString *credentials = [NSString stringWithFormat:@"%@:%@", theUserName, thePassword];
    return [BMEncodingHelper base64EncodedStringForData:[credentials dataUsingEncoding:NSUTF8StringEncoding]];
}


@end

