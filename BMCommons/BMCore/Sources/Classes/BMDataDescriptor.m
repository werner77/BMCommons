//
//  BMDataDescriptor.m
//  BMCommons
//
//  Created by Werner Altewischer on 01/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMDataDescriptor.h"

@implementation BMDataDescriptor 

@synthesize fileName = _fileName;
@synthesize contentType = _contentType;
@synthesize data = _data;
@synthesize compress = _compress;
@synthesize encodeBase64 = _encodeBase64;


+ (BMDataDescriptor *)dataDescriptorWithFileName:(NSString *)fileName contentType:(NSString *)contentType data:(NSData *)data {
    BMDataDescriptor *ret = [BMDataDescriptor new];
    ret.fileName = fileName;
    ret.contentType = contentType;
    ret.data = data;
    return ret;
}

@end
