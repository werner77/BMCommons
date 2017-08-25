//
//  UIImageToJPEGDataTransformer.h
//  BMCommons
//
//  Created by W. Altewischer on 7/13/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Value transformer for transforming a UIImage to NSData with JPEG encoding.
 */
@interface UIImageToJPEGDataTransformer : NSValueTransformer {

}

@end

NS_ASSUME_NONNULL_END
