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

@interface BMCompressDataTransformer : NSValueTransformer

/**
 Compression to use: default is ZLIB.
 */
@property (nonatomic, assign) BMCompressionType compressionType;

@end

NS_ASSUME_NONNULL_END
