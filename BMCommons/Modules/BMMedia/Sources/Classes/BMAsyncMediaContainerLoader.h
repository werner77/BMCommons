//
//  BMAsyncLoadingMediaContainer.h
//  BMCommons
//
//  Created by Werner Altewischer on 19/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaContainer.h>

/**
 This class provides functionality for loading the data for a BMMediaContainer.
 
 @see BMMediaContainerLoader
 */
@interface BMAsyncMediaContainerLoader : NSObject<BMMediaContainerLoader>

/**
 The wrapped media container.
 */
@property (nonatomic, strong) id<BMMediaContainer> media;

/**
 Error image to set for the media if loading was unsuccessful.
 */
@property (nonatomic, strong) UIImage *errorImage;

/**
 Initializes with the specified media container.
 */
- (id)initWithMedia:(id <BMMediaContainer>)mediaContainer;

/**
 * Sets the default error image when no errorImage is explicitly defined.
 */
+ (void)setDefaultErrorImage:(UIImage *)image;

@end
