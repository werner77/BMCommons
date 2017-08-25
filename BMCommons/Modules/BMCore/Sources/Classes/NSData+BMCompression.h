//
//  NSData+Compression.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/28/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
- (nullable NSData *)bmEncodeCOBS;
- (nullable NSData *)bmDecodeCOBS;

/**
 ZLIB decompression.
 */
- (nullable NSData *)bmZlibInflate;

/**
 ZLIB compression.
 */
- (nullable NSData *)bmZlibDeflate;

/**
 GZIP decompression.
 */
- (nullable NSData *)bmGzipInflate;

/**
 GZIP compression.
 */
- (nullable NSData *)bmGzipDeflate;

/**
 CRC32 checksum.
 */
- (uint32_t)bmCRC32;

@end

NS_ASSUME_NONNULL_END