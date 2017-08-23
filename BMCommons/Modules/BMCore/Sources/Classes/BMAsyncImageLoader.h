//
//  BMAsyncImageLoader.h
//  BMCommons
//
//  Created by Werner Altewischer on 20/05/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

//Class is only available for iOS

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import <BMCommons/BMAsyncDataLoader.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Async data loader for loading images.
 
 Uses BMURLCache for storing images.
 */
@interface BMAsyncImageLoader : BMAsyncDataLoader {
}

#if TARGET_OS_IPHONE

/**
 The returned image after loading completes.
 */
@property (nonatomic, readonly, nullable) UIImage *image;

#endif

@end

@interface BMAsyncImageLoader(Protected)

#if TARGET_OS_IPHONE

/**
 * Sets the image to return.
 *
 * @param theImage The image
 */
- (void)setImage:(nullable UIImage *)theImage;

#endif

@end

NS_ASSUME_NONNULL_END



