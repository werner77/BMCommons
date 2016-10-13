//
//  BMHTTPMultiPartBodyInputStream.m
//  BMCommons
//
//  Created by Werner Altewischer on 07/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMHTTPMultiPartBodyInputStream.h"
#import "BMHTTPContentPart.h"
#import "BMStringHelper.h"
#import <BMCore/BMCore.h>

@interface BMHTTPMultiPartBodyInputStream() 

@property (nonatomic, strong) NSInputStream *currentContentPartHeaderInputStream;
@property (nonatomic, strong) NSInputStream *currentContentPartDataInputStream;

@end

@interface BMHTTPMultiPartBodyInputStream(Private)

- (BMHTTPContentPart *)currentContentPart;
- (NSData *)readCurrentContentPartHeaders;
- (NSData *)readHeadersForPart:(BMHTTPContentPart *)contentPart isFirst:(BOOL)isFirst log:(BOOL)log;
- (NSInteger)readFromStream:(NSInputStream *)stream buffer:(uint8_t *)buffer maxLength:(NSUInteger)len;

@end

@implementation BMHTTPMultiPartBodyInputStream 

@synthesize currentContentPartHeaderInputStream = _currentContentPartHeaderInputStream, currentContentPartDataInputStream = _currentContentPartDataInputStream;

- (id)initWithContentParts:(NSArray *)theContentParts boundaryString:(NSString *)theBoundaryString {
    if ((self = [self init])) {
        _contentParts = theContentParts;
        _boundaryString = theBoundaryString;
        _currentContentPartIndex = -1;
        _totalBytesRead = 0;
    }
    return self;
}

- (void)dealloc {
    [self close];
    
    
}

- (void)reset {
    [self close];
    _streamStatus = NSStreamStatusNotOpen;
    _currentContentPartIndex = -1;
    _totalBytesRead = 0;
}

- (void)open {
    [super open];
    _currentContentPartIndex = -1;
    _totalBytesRead = 0;
}

- (void)close {
    [_currentContentPartDataInputStream close];
    [_currentContentPartHeaderInputStream close];
    self.currentContentPartDataInputStream = nil;
    self.currentContentPartHeaderInputStream = nil;
    [super close];
}

- (NSUInteger)length {
    if (_calculatedLength == 0) {
        NSUInteger length = 0;
        BOOL first = YES;
        for (BMHTTPContentPart *contentPart in _contentParts) {
            length += [self readHeadersForPart:contentPart isFirst:first log:NO].length;
            first = NO;
            length += contentPart.dataLength;
        }
        if (length > 0) {
            length += [self readHeadersForPart:nil isFirst:NO log:NO].length;
        }
        _calculatedLength = length;
    }
    return _calculatedLength;
}

- (NSUInteger)totalBytesRead {
    return _totalBytesRead;
}

// reads up to length bytes into the supplied buffer, which must be at least of size len. Returns the actual number of bytes read.
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len {
    NSInteger bytesRead = 0;
    do {
        if (self.currentContentPartHeaderInputStream) {
            bytesRead = [self readFromStream:self.currentContentPartHeaderInputStream buffer:buffer maxLength:len];
            if (bytesRead > 0) {
                break;
            } else {
                self.currentContentPartHeaderInputStream = nil;
                BMHTTPContentPart *part = self.currentContentPart;
                if (bytesRead == 0 && part) {
                    self.currentContentPartDataInputStream = part.dataStream;
                    [self.currentContentPartDataInputStream open];    
                }
            }
        } 
        if (self.currentContentPartDataInputStream) {
            bytesRead = [self readFromStream:self.currentContentPartDataInputStream buffer:buffer maxLength:len];
            if (bytesRead > 0) {
                break;
            } else {
                [_currentContentPartDataInputStream close];
                self.currentContentPartDataInputStream = nil;
            }
        }
        
        if (_streamStatus == NSStreamStatusError) {
            break;
        }
        
        //See whether there are more content parts. The last header part is the end line finishing the multipart body
        if (++_currentContentPartIndex <= _contentParts.count) {
            NSData *headerData = [self readCurrentContentPartHeaders];
            if (!headerData) {
                _streamStatus = NSStreamStatusAtEnd;
                break;
            }
            self.currentContentPartHeaderInputStream = [NSInputStream inputStreamWithData:headerData];
            [self.currentContentPartHeaderInputStream open];
        } else {
            //Finished
            _streamStatus = NSStreamStatusAtEnd;
            break;
        }
    } while (YES);
    
    if (bytesRead > 0) {
        _totalBytesRead += bytesRead;
    }
    
    return bytesRead;
}

// returns YES if the stream has bytes available or if it impossible to tell without actually doing the read.
- (BOOL)hasBytesAvailable {
    return _streamStatus != NSStreamStatusAtEnd;
}

@end

@implementation BMHTTPMultiPartBodyInputStream(Private)

- (BMHTTPContentPart *)currentContentPart {
    return ((_currentContentPartIndex >= 0 && _currentContentPartIndex < _contentParts.count) ? [_contentParts objectAtIndex:_currentContentPartIndex] : nil);
}

- (NSData *)readHeadersForPart:(BMHTTPContentPart *)contentPart isFirst:(BOOL)isFirst log:(BOOL)log {
    NSMutableData *buffer = [NSMutableData data];
    if (isFirst) {
        if (!contentPart) {
            return nil;
        }
        //First content part
        [buffer appendData:[BMStringHelper dataRepresentationOfString:[NSString stringWithFormat:@"--%@\r\n", _boundaryString]]];
    } else if (_currentContentPartIndex > 0 && contentPart) {
        //Intermediate part
        [buffer appendData:[BMStringHelper dataRepresentationOfString:[NSString stringWithFormat:@"\r\n--%@\r\n", _boundaryString]]];
    } else {
        //End line
        [buffer appendData:[BMStringHelper dataRepresentationOfString:[NSString stringWithFormat:@"\r\n--%@--\r\n", _boundaryString]]];
    }
    
    if (contentPart) {
        for (NSString *key in contentPart.headers) {
            NSString *value = [contentPart.headers objectForKey:key];
            NSString *s = [NSString stringWithFormat:@"%@: %@\r\n", key, value];
            [buffer appendData:[BMStringHelper dataRepresentationOfString:s]];
            if (log) {
                LogDebug(@"%@", s);
            }
        }
        [buffer appendData:[BMStringHelper dataRepresentationOfString:@"\r\n"]];        
    }
    return buffer;
}

- (NSData *)readCurrentContentPartHeaders {
    LogDebug(@"Adding content part with headers: ");
    
    BMHTTPContentPart *contentPart = self.currentContentPart;
    return [self readHeadersForPart:contentPart isFirst:(_currentContentPartIndex == 0) log:YES];
}

- (NSInteger)readFromStream:(NSInputStream *)stream buffer:(uint8_t *)buffer maxLength:(NSUInteger)len {
    NSInteger bytesRead = [stream read:buffer maxLength:len];
    if (bytesRead <= 0) {
        if (bytesRead < 0 && _streamError != stream.streamError) {
            _streamError = stream.streamError;    
        }
        [stream close];
        if (bytesRead < 0) {
            _streamStatus = NSStreamStatusError;
        }
    }
    return bytesRead;
}

@end
