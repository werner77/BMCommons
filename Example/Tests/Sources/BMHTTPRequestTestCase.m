//
//  BMHTTPRequestTestCase.m
//  BMCommons
//
//  Created by Werner Altewischer on 2/4/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMHTTPRequestTestCase.h"
#import <BMCommons/BMCore.h>
#import <BMCommons/NSCondition+BMCommons.h>

@interface BMHTTPRequestTestCase()

@property (nonatomic, strong) NSCondition *waitCondition;

@property (nonatomic, strong) BMHTTPRequest *httpRequest;

@end

@implementation BMHTTPRequestTestCase {
}

typedef void (^BMHTTPRequestCompletionBlock)(NSInteger responseCode, NSData *replyData, NSError *error);

- (void)setUp {
    self.waitCondition = [NSCondition new];
}

- (void)tearDown {
}

- (void)sendTestRequestWithCompletion:(BMHTTPRequestCompletionBlock)completion {
    _httpRequest = [[BMHTTPRequest alloc] initWithUrl:[NSURL URLWithString:@"http://ms-dev.ah.nl"] customHeaderFields:nil userName:nil password:nil delegate:self];
    _httpRequest.context = [completion copy];
    [_httpRequest send];
    
    
    [self waitForStatus:BMAsyncTestCaseStatusSucceeded timeout:1000.0];
}

- (void)sendTestRequestWithIndex:(NSUInteger)index maxCount:(NSUInteger)maxCount {
    if (index < maxCount) {
        LogDebug(@"Performing test request");
        [self sendTestRequestWithCompletion:^(NSInteger responseCode, NSData *replyData, NSError *error) {
            [NSThread sleepForTimeInterval:25.0];
            [self sendTestRequestWithIndex:(index + 1) maxCount:maxCount];
        }];
    } else {
        [self notify:BMAsyncTestCaseStatusSucceeded];
    }
}

- (void)testConnectionError {
    [self sendTestRequestWithIndex:0 maxCount:10];
}

- (void)requestSucceeded:(BMHTTPRequest *)theRequest {
    if (theRequest == self.httpRequest) {
        LogInfo(@"Http Request succeeded with httpResponseCode: %i and bytes: %i", theRequest.httpResponseCode, [theRequest.replyData length]);
        
        BMHTTPRequestCompletionBlock completionBlock = theRequest.context;
        if (completionBlock) {
            completionBlock(theRequest.httpResponseCode, theRequest.replyData, theRequest.lastError);
        }
        
        self.httpRequest = nil;
    }
}

- (void)requestFailed:(BMHTTPRequest *)theRequest {
    if (theRequest == self.httpRequest) {
        LogError(@"Http Request failed with httpResponseCode = %i and lastError = %@", theRequest.httpResponseCode, theRequest.lastError);
        
        BMHTTPRequestCompletionBlock completionBlock = theRequest.context;
        if (completionBlock) {
            completionBlock(theRequest.httpResponseCode, theRequest.replyData, theRequest.lastError);
        }
        
        self.httpRequest = nil;
    }
}

@end
