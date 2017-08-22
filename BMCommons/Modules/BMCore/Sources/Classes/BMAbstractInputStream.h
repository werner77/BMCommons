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
        NSError* _Nullable _streamError;
        const void* _Nullable _currentData;
        long _currentDataLength;
}

/**
 The current stream status.
 
 @see NSStreamStatus
 */
@property (readonly) NSStreamStatus streamStatus;

/**
 The last stream error if any.
 */
@property (nullable, copy, readonly) NSError* streamError;

/**
 The delegate for this stream.
 
 @see NSStreamDelegate
 */
@property (nullable, weak) id<NSStreamDelegate> delegate;

@end
