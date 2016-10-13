//
//  NSData+Compression.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/28/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Compression helper methods as category on NSData.
 */
@interface NSData(BMCompression)

/**
 Returns range [start, null byte), or (NSNotFound, 0).
 */
- (NSRange)bmRangeOfNullTerminatedBytesFrom:(NSUInteger)start;

/**
 COBS is an encoding that eliminates 0x00.
 */
- (NSData *)bmEncodeCOBS;
- (NSData *)bmDecodeCOBS;

/**
 ZLIB decompression.
 */
- (NSData *)bmZlibInflate;

/**
 ZLIB compression.
 */
- (NSData *)bmZlibDeflate;

/**
 GZIP decompression.
 */
- (NSData *)bmGzipInflate;

/**
 GZIP compression.
 */
- (NSData *)bmGzipDeflate;

/**
 CRC32 checksum.
 */
- (uint32_t)bmCRC32;

@end
