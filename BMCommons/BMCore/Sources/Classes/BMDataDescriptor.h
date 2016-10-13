//
//  BMDataDescriptor.h
//  BMCommons
//
//  Created by Werner Altewischer on 01/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMCoreObject.h>

/**
 A descriptor for data containing a filename, contentType, data, whether it is or should be compressed and/or base64 encoded.
 */
@interface BMDataDescriptor : BMCoreObject {
    @private
    NSString *_fileName;
    NSString *_contentType;
    NSData *_data;
    BOOL _compress;
    BOOL _encodeBase64;
}

/**
 The filename for the data.
 */
@property (nonatomic, strong) NSString *fileName;

/**
 The content type for the data.
 
 @see BMMIMEType
 */
@property (nonatomic, strong) NSString *contentType;

/**
 The actual data.
 */
@property (nonatomic, strong) NSData *data;

/**
 Whether compression is or should be applied to the data.
 */
@property (nonatomic, assign) BOOL compress;

/**
 Whether the data is or should be encoded with BASE-64 encoding.
 */
@property (nonatomic, assign) BOOL encodeBase64;

+ (BMDataDescriptor *)dataDescriptorWithFileName:(NSString *)fileName contentType:(NSString *)contentType data:(NSData *)data;

@end
