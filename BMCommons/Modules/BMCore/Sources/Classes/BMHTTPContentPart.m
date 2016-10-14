//
//  BMHTTPContentPart.m
//  BMCommons
//
//  Created by Werner Altewischer on 01/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMHTTPContentPart.h>
#import <BMCommons/BMEncodingHelper.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMDataDescriptor.h>
#import <BMCommons/BMMIMEType.h>
#import "NSData+BMCompression.h"

#define TEXT_CONTENT_TYPE @"text/plain; charset=UTF-8"
#define BINARY_CONTENT_TYPE @"application/octet-stream"
#define ZIP_CONTENT_TYPE @"application/x-gzip"

@interface BMHTTPContentPart(Private)

+ (void)setContentDispositionHeader:(NSMutableDictionary *)headers withName:(NSString *)name fileName:(NSString *)fileName;
+ (void)setContentTypeHeader:(NSMutableDictionary *)headers withContentType:(NSString *)contentType;

@end

@implementation BMHTTPContentPart 

@synthesize dataStream = _dataStream;
@synthesize headers = _headers;
@synthesize dataLength = _dataLength;


+ (BMHTTPContentPart *)contentPartWithHeaders:(NSDictionary *)headers dataStream:(NSInputStream *)dataStream {
    BMHTTPContentPart *part = [BMHTTPContentPart new];
    part.headers = headers;
    part.dataStream = dataStream;
    return part;
}

+ (BMHTTPContentPart *)contentPartWithHeaders:(NSDictionary *)headers data:(NSData *)theData {
    BMHTTPContentPart *contentPart = [self contentPartWithHeaders:headers dataStream:[NSInputStream inputStreamWithData:theData]];
    contentPart.dataLength = theData.length;
    return contentPart;
}

+ (BMHTTPContentPart *)contentPartWithName:(NSString *)name andValue:(NSString *)value {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self setContentDispositionHeader:headers withName:name fileName:nil];
    [self setContentTypeHeader:headers withContentType:TEXT_CONTENT_TYPE];
    return [self contentPartWithHeaders:headers 
                                  data:[BMStringHelper dataRepresentationOfString:value]];
}

+ (BMHTTPContentPart *)contentPartWithName:(NSString *)name filename:(NSString *)filename data:(NSData *)data encodeBase64:(BOOL)encodeBase64 compress:(BOOL)compress contentType:(NSString *)contentType {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [self setContentDispositionHeader:headers withName:name fileName:filename];
    if (compress){
        contentType = ZIP_CONTENT_TYPE;
    }
    [self setContentTypeHeader:headers withContentType:contentType];
    
    if (encodeBase64) {
        data = [BMEncodingHelper base64EncodedDataForData:data];
        [headers setObject:@"base64" forKey:BM_HTTP_CONTENT_TRANSFER_ENCODING_HEADER];
    }
    
    if (compress) {
        data = [data bmGzipDeflate];
    }
    return [self contentPartWithHeaders:headers data:data];
}

+ (BMHTTPContentPart *)contentPartWithName:(NSString *)name fileURL:(NSURL *)fileURL {
    NSString *ext = [[fileURL path] pathExtension];
    BMMIMEType *mimeType = [BMMIMEType mimeTypeForFileExtension:ext];
    return [self contentPartWithName:name fileURL:fileURL contentType:mimeType.contentType];
}

+ (BMHTTPContentPart *)contentPartWithName:(NSString *)name fileURL:(NSURL *)fileURL contentType:(NSString *)contentType {
    NSString *atomicFileName = [[fileURL path] lastPathComponent];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    
    [self setContentDispositionHeader:headers withName:name fileName:atomicFileName];
    [self setContentTypeHeader:headers withContentType:contentType];
    
    BMHTTPContentPart *contentPart = [self contentPartWithHeaders:headers dataStream:[NSInputStream inputStreamWithURL:fileURL]];
    
    if ([fileURL isFileURL]) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileURL path] error:nil];
        NSNumber *n = [attributes objectForKey:NSFileSize];
        if (n) {
            contentPart.dataLength = [n unsignedIntegerValue];
        }
    }
    return contentPart;
}

+ (NSArray *)contentPartsFromParameters:(NSDictionary *)parameters {
    NSMutableArray *parts = [NSMutableArray array];
    for (NSString *key in parameters) {
        id value = [parameters objectForKey:key];
        
        NSString *stringValue = nil;
        if ([value isKindOfClass:[NSNumber class]]) {
            stringValue = [(NSNumber *)value stringValue];
        } else if ([value isKindOfClass:[NSString class]]) {
            stringValue = value;
        } else if ([value isKindOfClass:[NSNull class]]) {
            //Ignore
            continue;
        }
        
        BMHTTPContentPart *part = nil;
        if (stringValue) {
            part = [self contentPartWithName:key andValue:stringValue];
        } else if ([value isKindOfClass:[NSURL class]]) {
            NSURL *fileURL = (NSURL *)value;
            part = [self contentPartWithName:key fileURL:fileURL];
        } else if  ([value isKindOfClass:[BMDataDescriptor class]]) {
            BMDataDescriptor *descriptor = value;
            part = [self contentPartWithName:key filename:descriptor.fileName data:descriptor.data encodeBase64:descriptor.encodeBase64 compress:descriptor.compress contentType:descriptor.contentType];
        } else {
            NSException *ex = [NSException exceptionWithName:@"IllegalArgumentException" reason:[NSString stringWithFormat:@"Invalid parameter supplied: %@", value] userInfo:nil];
            @throw ex;
        }
        [parts addObject:part];
    }
    return parts;
}

@end


@implementation BMHTTPContentPart(Private)

+ (void)setContentDispositionHeader:(NSMutableDictionary *)headers withName:(NSString *)name fileName:(NSString *)fileName {
    NSString *s = [NSString stringWithFormat:@"form-data; name=\"%@\"", name];
    
    if (fileName) {
        s = [s stringByAppendingFormat:@"; filename=\"%@\"", fileName];
    }
    [headers setObject:s forKey:BM_HTTP_CONTENT_DISPOSITION_HEADER];
}

+ (void)setContentTypeHeader:(NSMutableDictionary *)headers withContentType:(NSString *)contentType {
    if (!contentType) {
        contentType = BINARY_CONTENT_TYPE;
    }
    [headers setObject:contentType forKey:BM_HTTP_CONTENT_TYPE_HEADER];
}

@end
