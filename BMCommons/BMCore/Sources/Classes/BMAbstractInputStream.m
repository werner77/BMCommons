//
//  BMAbstractInputStream.m
//
//  Created by Werner Altewischer on 12/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAbstractInputStream.h>
#import <BMCommons/BMCore.h>

@implementation BMAbstractInputStream


@synthesize streamStatus = _streamStatus;
@synthesize streamError = _streamError;
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [super init])) {
        _streamStatus = NSStreamStatusNotOpen;
        [self setDelegate:self];
	}
	return self;
}


// reads up to length bytes into the supplied buffer, which must be at least of size len. Returns the actual number of bytes read.
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    if (_currentData) {
        NSUInteger copiedBytes = _currentDataLength;
        if (copiedBytes > len)
            copiedBytes = len;
        memcpy(buffer,_currentData,copiedBytes);
        _currentData += copiedBytes;
        _currentDataLength -= copiedBytes;
        return copiedBytes;
    } else {
        return 0;
    }
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
    return NO;
}

- (BOOL)hasBytesAvailable
{
    return (_currentDataLength != 0);
}

- (id)propertyForKey:(NSString *)key
{
    return nil;
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key
{
    return NO;
}

- (void)open
{
    _streamStatus = NSStreamStatusOpen;
}

- (void)close
{
	_streamStatus = NSStreamStatusClosed;
}

- (id<NSStreamDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<NSStreamDelegate>)aDelegate {
    _delegate = aDelegate;
    if (_delegate == nil) {
    	_delegate = self;
    }
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {
    // Nothing to do here, because this stream does not need a run loop to produce its data.
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {
    // Nothing to do here, because this stream does not need a run loop to produce its data.
}

- (NSStreamStatus)streamStatus {
    return _streamStatus;
}

- (NSError *)streamError {
    return _streamError;
}

#pragma mark - Undocumented CFReadStream bridged methods

- (void)_scheduleInCFRunLoop:(CFRunLoopRef)aRunLoop forMode:(CFStringRef)aMode {
	// Nothing to do here, because this stream does not need a run loop to produce its data.
}

- (BOOL)_setCFClientFlags:(CFOptionFlags)inFlags
                 callback:(CFReadStreamClientCallBack)inCallback
                  context:(CFStreamClientContext *)inContext {
    
	if (inCallback != NULL) {
		_requestedEvents = inFlags;
		_copiedCallback = inCallback;
		memcpy(&_copiedContext, inContext, sizeof(CFStreamClientContext));
        
		if (_copiedContext.info && _copiedContext.retain) {
			_copiedContext.retain(_copiedContext.info);
		}
        
		_copiedCallback((__bridge CFReadStreamRef)self, kCFStreamEventHasBytesAvailable, &_copiedContext);
	}
	else {
		_requestedEvents = kCFStreamEventNone;
		_copiedCallback = NULL;
		if (_copiedContext.info && _copiedContext.release) {
			_copiedContext.release(_copiedContext.info);
		}
        
		memset(&_copiedContext, 0, sizeof(CFStreamClientContext));
	}
    
	return YES;	
    
}

- (void)_unscheduleFromCFRunLoop:(CFRunLoopRef)aRunLoop forMode:(CFStringRef)aMode {
	// Nothing to do here, because this stream does not need a run loop to produce its data.
} 

@end
