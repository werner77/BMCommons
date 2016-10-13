//
//  BMURLConnectionInputStream.h
//
//  Created by Werner Altewischer on 12/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMAbstractInputStream.h>

@class BMURLConnectionInputStream;

/**
 Inputstream that reads from a NSURLConnection.
 */

@protocol BMURLConnectionInputStreamDelegate <NSStreamDelegate>

@optional
- (BOOL)stream:(BMURLConnectionInputStream *)inputStream isRetriableError:(NSError *)error withRetryCount:(NSUInteger)retryCount;

@end

@interface BMURLConnectionInputStream  : BMAbstractInputStream {
@private
    NSURLConnection* _connection;
    id __weak _urlConnectionDelegate;
}

/**
 Delegate to forward the NSURLConnection delegate callbacks to.
 
 @see NSURLConnectionDelegate
 */
@property (nonatomic, weak) id urlConnectionDelegate;

/**
 Delegate for the input stream.
 */
@property (weak) id <BMURLConnectionInputStreamDelegate> delegate;

/**
Initializes the stream with the specified request and NSURLConnectionDelegate.
*/
- (id)initWithRequest:(NSURLRequest*)request urlConnectionDelegate:(id)urlConnectionDelegate;

/**
 Initializes the stream with the specified request and nil NSURLConnectionDelegate.
 */
- (id)initWithRequest:(NSURLRequest*)request;

@end
