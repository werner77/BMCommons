//
//  BMHTTPMultiPartBodyInputStream.h
//  BMCommons
//
//  Created by Werner Altewischer on 07/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMAbstractInputStream.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Inputstream for doing a HTTP multipart post with specified content parts in a streaming fashion.
 
 This stream reads the data for the contentParts and appends them using the specified boundary string.
 
 @see BMHTTPContentPart
 @see BMHTTPRequest
 */
@interface BMHTTPMultiPartBodyInputStream : BMAbstractInputStream

/**
 * The boundary string that was set or generated (if nil was supplied).
 */
@property (nonatomic, readonly) NSString *boundaryString;

/**
 Initializes with the specified array of BMHTTPContentPart instances and unique boundary string to separate the parts in the multipart body.
 
 @param contentParts Instances of BMHTTPContentPart.
 @param boundaryString A unique string to separate the content parts from each other. This string should not occur in the data of any of the content parts.
 If nil is supplied a default random boundary string will be generated.
 */
- (id)initWithContentParts:(NSArray *)contentParts boundaryString:(nullable NSString *)boundaryString;

/**
 Resets the stream.
 */
- (void)reset;

/**
 Total number of bytes to read.
 */
- (NSUInteger)length;

/**
 Bytes read up to this point.
 */
- (NSUInteger)totalBytesRead;

@end

NS_ASSUME_NONNULL_END
