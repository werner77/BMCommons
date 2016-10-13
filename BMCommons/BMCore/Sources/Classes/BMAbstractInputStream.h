//
//  BMAbstractInputStream.h
//
//  Created by Werner Altewischer on 12/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Base class for input streams.
 
 Contains a buffer for the data received and a counter for the number of bytes received. Also keeps track of the stream status (open, closed, etc).
 */
@interface BMAbstractInputStream : NSInputStream<NSStreamDelegate> {
    @protected
    NSStreamStatus _streamStatus;
    NSError* _streamError;
    const void* _currentData;
    long _currentDataLength;
    
    @private
    CFReadStreamClientCallBack _copiedCallback;
	CFStreamClientContext _copiedContext;
    CFOptionFlags _requestedEvents;
	id<NSStreamDelegate> __weak _delegate;
}

/**
 The current stream status.
 
 @see NSStreamStatus
 */
@property (readonly) NSStreamStatus streamStatus;

/**
 The last stream error if any.
 */
@property (copy, readonly) NSError* streamError;

/**
 The delegate for this stream.
 
 @see NSStreamDelegate
 */
@property (weak) id<NSStreamDelegate> delegate;

@end
