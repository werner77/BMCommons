//
//  NSData+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 13/11/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "NSData+BMCommons.h"
#import <BMCore/BMEncodingHelper.h>

@implementation NSData (BMCommons)

- (NSString *)bmStringUsingEncoding:(NSStringEncoding)encoding {
    return [[NSString alloc] initWithData:self encoding:encoding];
}

- (NSString *)bmHexEncodedString {
    return [BMEncodingHelper hexEncodedStringForData:self];
}

- (NSString *)bmBase64EncodedString {
    return [BMEncodingHelper base64EncodedStringForData:self];
}

- (BOOL)bmIsJPGData {
    if (self.length > 4)
    {
        unsigned char buffer[4];
        [self getBytes:&buffer length:4];
        
        return buffer[0]==0xff &&
        buffer[1]==0xd8 &&
        buffer[2]==0xff;
    }
    return NO;
}

- (BOOL)bmIsPNGData {
    if (self.length > 4)
    {
        unsigned char buffer[4];
        [self getBytes:&buffer length:4];
        
        return buffer[0]==0x89 &&
        buffer[1]==0x50 &&
        buffer[2]==0x4e &&
        buffer[3]==0x47;
    }
    
    return NO;
}

@end
