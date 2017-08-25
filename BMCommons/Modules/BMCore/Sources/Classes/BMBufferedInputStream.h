//
//  BMBufferedInputStream.h
//  BMCommons
//
//  Created by Werner Altewischer on 3/2/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Inputstream that adds in-memory buffering to the underlying inputstream.
 */
@interface BMBufferedInputStream : NSInputStream

/**
 Returns the number of bytes that have currently been processed by the decorator
 */
@property (readonly) NSUInteger bytesProcessed;

/**
 Creates a new decorator with the given stream, chunk size, and encoding
 */
- (id)initWithInputStream:(NSInputStream *)stream bufferSize:(NSUInteger)bufSize encoding:(NSStringEncoding)encoding NS_DESIGNATED_INITIALIZER;

/**
 Read a new line of text from the underlying stream
 */
- (nullable NSString *)readLine;

@end

NS_ASSUME_NONNULL_END

