//
//  BMMediaContainerPhoto.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/Three20UI/BMTTPhoto.h>
#import <BMMedia/BMMediaContainer.h>

/**
 Implementation of BMTTPhoto which wraps one or multiple instances of BMMediaContainer.
 
 In the case multiple BMMediaContainers are wrapped, they are shown in a slideshow using crossfade animations.
 */
@interface BMMediaContainerPhoto : NSObject<BMTTPhoto>

/**
 The array of BMMediaContainer instances wrapped by this instance.
 */
@property(strong, nonatomic, readonly) NSArray *medias;

/**
 Init with a single BMMediaContainer.
 */
- (id)initWithMedia:(id <BMMediaContainer>)theMedia;

/**
 Init with an array of BMMediaContainer instances for use in slideshow.
 */
- (id)initWithMedias:(NSArray *)theMedias;


- (id <BMMediaContainer>)media;
- (void)removeMedia:(id <BMMediaContainer>)theMedia;
- (void)setActiveMedia:(id <BMMediaContainer>)theMedia;
- (void)setActiveMediaIndex:(NSUInteger)index;
- (BMMediaOrientation)orientation;

@end
