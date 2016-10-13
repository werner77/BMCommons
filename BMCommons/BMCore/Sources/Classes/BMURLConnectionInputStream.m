//
//  BMCommonsURLConnectionInputStream.m
//
//  Created by Werner Altewischer on 12/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import "BMURLConnectionInputStream.h"
#import "BMLogging.h"
#import <BMCommons/BMCore.h>

@interface BMURLConnectionInputStream()

@property (strong) NSURLRequest *request;

@end

@implementation BMURLConnectionInputStream {
    NSUInteger _retryCount;
}

@dynamic delegate;

@synthesize urlConnectionDelegate = _urlConnectionDelegate;

- (id)initWithRequest:(NSURLRequest*)request urlConnectionDelegate:(id)theDelegate
{
    if ((self = [super init])) {
        self.request = request;
        [self initializeConnection];
		_urlConnectionDelegate = theDelegate;
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest*)request {
	return [self initWithRequest:request urlConnectionDelegate:nil];
}

- (void)initializeConnection {
    _connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
    _streamStatus = NSStreamStatusNotOpen;
}

- (void) dealloc {
    [self close];
	self.urlConnectionDelegate = nil;
    BM_RELEASE_SAFELY(_connection);
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)setUrlConnectionDelegate:(id)urlDelegate {
	_urlConnectionDelegate = urlDelegate;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    _streamStatus = NSStreamStatusOpen;
	if ([_urlConnectionDelegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
		[_urlConnectionDelegate connection:theConnection didReceiveResponse:response];
	}
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
    _streamStatus = NSStreamStatusOpen;
    _currentData = [data bytes];
    _currentDataLength = [data length];
    while (_currentDataLength != 0 && [self.delegate respondsToSelector:@selector(stream:handleEvent:)]) {
        [self.delegate stream:self handleEvent:NSStreamEventHasBytesAvailable];
    }
    _currentData = 0;
    _currentDataLength = 0;
	if ([_urlConnectionDelegate respondsToSelector:@selector(connection:didReceiveData:)]) {
		[_urlConnectionDelegate connection:theConnection didReceiveData:data];
	}
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    BOOL retry = NO;
    if (_streamStatus == NSStreamStatusOpening && [self.delegate respondsToSelector:@selector(stream:isRetriableError:withRetryCount:)]) {
        retry = [self.delegate stream:self isRetriableError:error withRetryCount:_retryCount];
    }
    
    if (retry) {
        [self reopen];
    } else {
        _streamStatus = NSStreamStatusError;
        _streamError = error;
        if ([_urlConnectionDelegate respondsToSelector:@selector(connection:didFailWithError:)]) {
            [_urlConnectionDelegate connection:theConnection didFailWithError:error];
        }
        [self.delegate stream:self handleEvent: NSStreamEventErrorOccurred];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    _streamStatus = NSStreamStatusAtEnd;
    if ([_urlConnectionDelegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
		[_urlConnectionDelegate connectionDidFinishLoading:theConnection];
	}
    [self.delegate stream:self handleEvent: NSStreamEventEndEncountered];
}

- (NSURLRequest *)connection:(NSURLConnection *)theConnection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
	if ([_urlConnectionDelegate respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)]) {
		return [_urlConnectionDelegate connection:theConnection willSendRequest:request redirectResponse:response];
	} else {
		return request;
	}
}

- (BOOL)connection:(NSURLConnection *)theConnection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	if ([_urlConnectionDelegate respondsToSelector:@selector(connection:canAuthenticateAgainstProtectionSpace:)]) {
		return [_urlConnectionDelegate connection:theConnection canAuthenticateAgainstProtectionSpace:protectionSpace];
	} else {
		return NO;
	}
}

- (void)connection:(NSURLConnection *)theConnection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([_urlConnectionDelegate respondsToSelector:@selector(connection:didReceiveAuthenticationChallenge:)]) {
		[_urlConnectionDelegate connection:theConnection didReceiveAuthenticationChallenge:challenge];
	}
}

- (void)connection:(NSURLConnection *)theConnection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([_urlConnectionDelegate respondsToSelector:@selector(connection:didCancelAuthenticationChallenge:)]) {
		[_urlConnectionDelegate connection:theConnection didCancelAuthenticationChallenge:challenge];
	}
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)theConnection {
	if ([_urlConnectionDelegate respondsToSelector:@selector(connectionShouldUseCredentialStorage:)]) {
		return [_urlConnectionDelegate connectionShouldUseCredentialStorage:theConnection];
	} else {
		return YES;
	}
}

- (NSInputStream *)connection:(NSURLConnection *)theConnection needNewBodyStream:(NSURLRequest *)request {
    if ([_urlConnectionDelegate respondsToSelector:@selector(connection:needNewBodyStream:)]) {
        return [_urlConnectionDelegate connection:theConnection needNewBodyStream:request];
    } else {
        return nil;
    }
}

- (void)connection:(NSURLConnection *)theConnection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	if ([_urlConnectionDelegate respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
		[_urlConnectionDelegate connection:theConnection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten
                totalBytesExpectedToWrite:totalBytesExpectedToWrite];
	}
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)theConnection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	if ([_urlConnectionDelegate respondsToSelector:@selector(connection:willCacheResponse:)]) {
		return [_urlConnectionDelegate connection:theConnection willCacheResponse:cachedResponse];
	} else {
		return cachedResponse;
	}
}

#pragma mark -
#pragma mark InputStream methods

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    [_connection scheduleInRunLoop:aRunLoop forMode:mode];
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
{
    [_connection unscheduleFromRunLoop:aRunLoop forMode:mode];
}

- (void)reopen {
    _retryCount++;
    [_connection cancel];
    _connection = nil;
    [self initializeConnection];
    [self open];
}

- (void)open
{
    _streamStatus = NSStreamStatusOpening;
    [_connection start];
}

- (void)close
{
	[_connection cancel];
    [super close];
}

@end
