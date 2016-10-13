//
//  BMHTTPContentPart.h
//  BMCommons
//
//  Created by Werner Altewischer on 01/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMCoreObject.h>

#define BM_HTTP_CONTENT_TYPE_HEADER @"Content-Type"
#define BM_HTTP_CONTENT_DISPOSITION_HEADER @"Content-Disposition"
#define BM_HTTP_CONTENT_TRANSFER_ENCODING_HEADER @"Content-Transfer-Encoding"

/**
 Class representing a content part in a multi-part HTTP POST request.
 */
@interface BMHTTPContentPart : BMCoreObject {
    @private
	NSInputStream *_dataStream;
	NSDictionary *_headers;
    NSUInteger _dataLength;
}

/**
 The total data length in bytes.
 */
@property (nonatomic, assign) NSUInteger dataLength;

/**
 Input stream for reading the data.
 */
@property (nonatomic, strong) NSInputStream *dataStream;

/**
 HTTP header dictionary.
 */
@property (nonatomic, strong) NSDictionary *headers;

/**
 Generic content part with supplied headers and data.
 */
+ (BMHTTPContentPart *)contentPartWithHeaders:(NSDictionary *)headers data:(NSData *)data;

/**
 Generic content part with supplied headers and data from an inputstream.
 */
+ (BMHTTPContentPart *)contentPartWithHeaders:(NSDictionary *)headers dataStream:(NSInputStream *)theDataStream;

/**
 Name/value content part
 */
+ (BMHTTPContentPart *)contentPartWithName:(NSString *)name andValue:(NSString *)value;

/**
 Content part for a file with the supplied data. 
 
 Optionally the data is encoded as base64 or compressed using gzip.
 ContentType is optional, defaults to application/octet-stream or application/x-gzip if compressed.
 
 @param name The name for the part which is encoded as "form-data; name=xxx" in the actual request
 @param filename The filename for this part which is encoded as form-data; filename=xxx" in the actual request.
 @param data The data for this content part
 @param encodeBase64 Whether the data should be BASE-64 encoded or not
 @param compress Whether the data should be compressed using gzip or not
 @param contentType The content type for this part. If compress == true this will be overridden with application/x-gzip.
 */
+ (BMHTTPContentPart *)contentPartWithName:(NSString *)name filename:(NSString *)filename data:(NSData *)data encodeBase64:(BOOL)encodeBase64 compress:(BOOL)compress contentType:(NSString *)contentType;

/**
 Content part for a file with the supplied URL. 
 
 Filename is determined automatically from the last part of the URL path.
 */
+ (BMHTTPContentPart *)contentPartWithName:(NSString *)name fileURL:(NSURL *)fileURL contentType:(NSString *)contentType;

/**
 Content part for a file with the supplied URL.
 
 Filename is determined automatically from the last part of the URL path. 
 The content type is determined automatically from the extension.
 
 @see BMMIMEType
 */
+ (BMHTTPContentPart *)contentPartWithName:(NSString *)name fileURL:(NSURL *)fileURL;

/**
 Constructs an array of content parts from the supplied parameters. 
 
 The key of the dictionary is the parameter name. The value can be any of the following types:

 - NSString or NSNumber: to specify a simple string parameter
 - NSNull: to ignore the parameter
 - NSURL: for a file attachment, the URL should point to the file in question
 - BMDataDescriptor: for data of generic type/with generic data
 
 @see BMDataDescriptor
 */
+ (NSArray *)contentPartsFromParameters:(NSDictionary *)parameters;

@end

