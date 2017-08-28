//
//  BMCompressDataTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 08/10/15.
//  Copyright © 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BMCompressionType) {
    BMCompressionTypeZLIB,
    BMCompressionTypeGZIP
};

/**
 * Value transformer which compresses NSData upon forward transformation and decompresses upon reverse transformation.
 */
@interface BMCompressDataTransformer : NSValueTransformer

/**
 Compression to use: default is ZLIB.
 */
@property (nonatomic, assign) BMCompressionType compressionType;

@end

NS_ASSUME_NONNULL_END
