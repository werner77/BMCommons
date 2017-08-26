//
//  BMParser.m
//  BMCommons
//
//  Created by Werner Altewischer on 2/3/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMParser.h>
#import <BMCommons/BMURLConnectionInputStream.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMCore.h>
#import <BMCommons/BMErrorHelper.h>

#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#endif

#define BUFFER_SIZE (100 * 1024)

@interface BMParser(Private)

- (BOOL)hasInput;
- (BOOL)inputHasBytesAvailable;
- (size_t)inputReadAvailableInitialBytes:(uint8_t*)buffer maxLength:(size_t)maxLength;
- (void)inputScheduleInRunLoop:(NSRunLoop*)theRunloop forMode:(NSString*)theMode;
- (void)inputRemoveFromRunLoop;
- (void)inputRunRunLoop;
- (NSUInteger)inputExpectedLength;
- (void)setStreamComplete: (BOOL) parsedOK;
- (uint8_t *)buffer;
- (void)freeBuffer;

@end

@implementation BMParser {
@private
	uint8_t *_buffer;
	NSInputStream * _stream;
	BOOL _streamComplete;

	NSRunLoop *_runloop;
	NSString *_runloopMode;

	id __weak _asyncDelegate;
	SEL _asyncSelector;
	id <NSObject> _asyncContext;
}

#pragma mark -
#pragma mark Initialization and deallocation

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (id)initWithData:(NSData *)data {
    NSInputStream *theStream = [[NSInputStream alloc] initWithData: data];
    if ((self = [self initWithStream:theStream])) {
        _totalDataLength = [data length];
    }
    return self;
}

- (id)initWithStream:(NSInputStream *)theStream {
	if ((self = [super init])) {
		_stream = theStream;
		if (_totalDataLength != 0.0 ) {
			_totalDataLength = [self inputExpectedLength];
		}
	}
	return self;
}

- (id) initWithResultOfURLRequest:(NSURLRequest*)request
{
    BMURLConnectionInputStream* theStream = [[BMURLConnectionInputStream alloc] initWithRequest:request];
    return [self initWithStream:theStream];
}

- (id)initWithContentsOfURL:(NSURL *)url
{
	NSURLRequest* request = [NSURLRequest requestWithURL:url];
	return [self initWithResultOfURLRequest:request];
}


- (void) dealloc
{
    if (_buffer) {
        free(_buffer);
        _buffer = nil;
    }
	[self inputRemoveFromRunLoop];
	[self parserDealloc];
}

#pragma mark -
#pragma mark NSStreamDelegate implementation

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    @synchronized(self) {
		NSInputStream * input = (NSInputStream *) theStream;
		switch ( streamEvent )
		{
			case NSStreamEventOpenCompleted:
				break;
			case NSStreamEventErrorOccurred: {
                self.parserError = [input streamError] ?: [BMErrorHelper genericErrorWithDescription:@"Unknown error"];
				if ( [self.delegate respondsToSelector: @selector(parser:parseErrorOccurred:)] ) {
					[self.delegate parser:self parseErrorOccurred:self.parserError];
				}
				[self setStreamComplete: NO];
				break;
			}
			case NSStreamEventEndEncountered: {
                [self parserFinished];
				[self setStreamComplete:(self.parserError == nil)];
				break;
			}
			case NSStreamEventHasBytesAvailable: {
				if (_parsingAborted)
					break;
				
				uint8_t *buf = self.buffer;
				NSInteger len = [input read:buf maxLength:BUFFER_SIZE];
				
				if ( len > 0 ) {
					[self parseData:buf length:len];
				}
				break;
			}
			default:
				break;	
		}
	}
}

#pragma mark -
#pragma mark Parsing

- (void) abortParsing
{
	if ([self isParsing]) {
		_parsingAborted = YES;
		[self inputRemoveFromRunLoop];
		[self parserAborted];
	}
}

- (void)stopParsing {
	[self abortParsing];
	[self setStreamComplete: NO]; // must tell any async delegates that we're done parsing
}

- (BOOL) parse
{
	if ( [self parseAsynchronouslyUsingRunLoop: [NSRunLoop currentRunLoop]
                                          mode: [BMStringHelper stringWithUUID]
                             notifyingDelegate: nil
                                      selector: NULL
                                       context: NULL] == NO )
    {
        return ( NO );
    }
	
	// run in the common runloop modes while we read the data from the stream
	do
	{
		@autoreleasepool {
            [self inputRunRunLoop];
		}
		
	} while (!_streamComplete);
	
    [self inputRemoveFromRunLoop];
	
	return (self.parserError == nil );
}



- (BOOL) parseAsynchronouslyUsingRunLoop: (NSRunLoop *) theRunloop
                                    mode: (NSString *) theMode
                       notifyingDelegate: (id) asyncCompletionDelegate
                                selector: (SEL) completionSelector
                                 context: (id <NSObject>) contextPtr
{
    if (![self hasInput])
        return NO;
	
	// see if bytes are already available on the stream
	// if there are, we'll grab the first 4 bytes and use those to compute the encoding
	// otherwise, we'll just go with no initial data
	uint8_t buf[4];
	size_t buflen = 0;
	
	_streamComplete = NO;
	
	if ( [self inputHasBytesAvailable] )
    {
		buflen = [self inputReadAvailableInitialBytes:buf maxLength: 4];
        [self initializeParserWithBytes: buf length: buflen];
    }
    
    // store async callbacks details
    _asyncDelegate = asyncCompletionDelegate;
    _asyncSelector = completionSelector;
	
	if (_asyncContext != contextPtr) {
		_asyncContext = contextPtr;
	}
	
    // start the stream processing going
    [self inputScheduleInRunLoop:theRunloop forMode:theMode];
    
    return ( YES );
}

- (BOOL)isParsing {
	return !_streamComplete;
}

@end

@implementation BMParser(Protected)

#pragma mark -
#pragma mark Protected methods


- (void)parserFinished {
	
}

- (void)parserAborted {
	
}

- (void)parseData:(const void *)bytes length:(NSUInteger)length {
	if (self.progressDelegate != nil && !_parsingAborted)
    {
		_parsedDataLength += length;
		float progress = ((float)self.parsedDataLength) / ((float)self.totalDataLength);
        [(id<BMParserProgressDelegate>)self.progressDelegate parser:self updateProgress:progress];
    }
}

- (void)initializeParserWithBytes: (const void *) buf length: (NSUInteger) length {
	
}

- (void)setParserError:(NSError *)theError {
	if (_parserError != theError) {
		_parserError = theError;
	}
}

- (void)parserDealloc {
	BM_RELEASE_SAFELY(_parserError);
	BM_RELEASE_SAFELY(_asyncContext);
    BM_RELEASE_SAFELY(_stream);
	BM_RELEASE_SAFELY(_runloopMode);
	BM_RELEASE_SAFELY(_runloop);
}

@end

@implementation BMParser(Private)

- (uint8_t *)buffer {
    if (!_buffer) {
        _buffer = malloc(BUFFER_SIZE * sizeof(uint8_t));
    }
    return _buffer;
}

- (void)freeBuffer {
    if (_buffer) {
        free(_buffer);
        _buffer = nil;
    }
}

- (BOOL) hasInput
{
    if ( _stream == nil )
		return ( NO );
    return YES;
}

- (BOOL) inputHasBytesAvailable
{
    return [_stream hasBytesAvailable];
}

- (size_t) inputReadAvailableInitialBytes:(uint8_t*)buffer maxLength:(size_t)maxLength
{
    return [_stream read: buffer maxLength: maxLength];
}

- (void)inputScheduleInRunLoop:(NSRunLoop*)theRunloop forMode:(NSString*)theMode
{
	if (_runloop != theRunloop) {
		_runloop = theRunloop;
	}
	
	if (_runloopMode != theMode) {
		_runloopMode = theMode;
	}
	
	[_stream setDelegate: self];
	[_stream scheduleInRunLoop:_runloop forMode:_runloopMode];
	
	if ( [_stream streamStatus] == NSStreamStatusNotOpen )
		[_stream open];
}

- (void)inputRemoveFromRunLoop
{
	if (_stream) {
		[_stream setDelegate: nil];
		[_stream removeFromRunLoop:_runloop
						   forMode:_runloopMode];
		[_stream close];
        _stream = nil;
        _runloop = nil;
		_runloopMode = nil;
	}
}

- (void)inputRunRunLoop
{
    [[NSRunLoop currentRunLoop] runMode:_runloopMode
                             beforeDate: [NSDate distantFuture]];
}

- (NSUInteger)inputExpectedLength
{
    NSUInteger result = 0.0;
    CFHTTPMessageRef msg = (__bridge CFHTTPMessageRef) [_stream propertyForKey: (NSString *)kCFStreamPropertyHTTPResponseHeader];
    if ( msg != NULL )
    {
        CFStringRef str = CFHTTPMessageCopyHeaderFieldValue( msg, CFSTR("Content-Length") );
        if ( str != NULL )
        {
            result = (NSUInteger)[(__bridge NSString *)str integerValue];
            CFRelease( str );
        }
        return result;
    }
    
    CFNumberRef num = (__bridge CFNumberRef) [_stream propertyForKey: (NSString *)kCFStreamPropertyFTPResourceSize];
    if ( num != NULL )
    {
        result = [(__bridge NSNumber *)num unsignedIntegerValue];
        return result;
    }
    
    // for some forthcoming stream classes...
    NSNumber * guess = [_stream propertyForKey: @"UncompressedDataLength"];
    if ( guess != nil )
        result = [guess unsignedIntegerValue];
    return result;
}


- (void) setStreamComplete: (BOOL) parsedOK
{
    [self freeBuffer];
	if (!_streamComplete) {
		_streamComplete = YES;
		
		if (_asyncDelegate != nil )
		{
			__unsafe_unretained id <NSObject> context = _asyncContext;
            __unsafe_unretained id unsafeSelf = self;
			
			NSInvocation * invoc = [NSInvocation invocationWithMethodSignature:[_asyncDelegate methodSignatureForSelector:_asyncSelector]];
			[invoc setTarget: _asyncDelegate];
			[invoc setSelector: _asyncSelector];
			[invoc setArgument: &unsafeSelf atIndex: 2];
			[invoc setArgument: &parsedOK atIndex: 3];
			[invoc setArgument: &context atIndex: 4];
			[invoc invoke];
		}
	}
}

@end
