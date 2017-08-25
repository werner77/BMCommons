//
//  BMURLConnectionInputStream.h
//
//  Created by Werner Altewischer on 12/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMAbstractInputStream.h>

@class BMURLConnectionInputStream;

NS_ASSUME_NONNULL_BEGIN

/**
 Inputstream that reads from a NSURLConnection.
 */

@protocol BMURLConnectionInputStreamDelegate <NSStreamDelegate>

@optional
- (BOOL)stream:(BMURLConnectionInputStream *)inputStream isRetriableError:(NSError *)error withRetryCount:(NSUInteger)retryCount;

@end

@interface BMURLConnectionInputStream  : BMAbstractInputStream

/**
 Delegate to forward the NSURLConnection delegate callbacks to.
 
 @see NSURLConnectionDelegate
 */
@property (nullable, nonatomic, weak) id urlConnectionDelegate;

/**
 Delegate for the input stream.
 */
@property (nullable, weak) id <BMURLConnectionInputStreamDelegate> delegate;

/**
Initializes the stream with the specified request and NSURLConnectionDelegate.
*/
- (nullable id)initWithRequest:(NSURLRequest*)request urlConnectionDelegate:(nullable id)urlConnectionDelegate NS_DESIGNATED_INITIALIZER;

/**
 Initializes the stream with the specified request and nil NSURLConnectionDelegate.
 */
- (nullable id)initWithRequest:(NSURLRequest*)request;

@end

NS_ASSUME_NONNULL_END
