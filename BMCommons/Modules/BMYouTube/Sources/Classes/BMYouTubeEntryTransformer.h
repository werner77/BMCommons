//
//  BMYouTubeEntryTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 08/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaContainer.h>
#import <GData/GDataYouTubeMediaElements.h>

typedef id<BMVideoContainer> (^BMVideoContainerConstructorBlock)();

/**
 Value tranformer for transforming a GDataEntryYouTubeVideo to a BMVideoContainer for downloading content from YouTube.
 */
@interface BMYouTubeEntryTransformer : NSValueTransformer

@property (nonatomic, readonly) id <BMVideoContainer> videoContainer;
@property (nonatomic, readonly) Class videoContainerClass;
@property (copy, nonatomic, readonly) BMVideoContainerConstructorBlock constructorBlock;

/**
 Initializer for populating the supplied BMVideoContainer instead of creating a new one.
 */
- (id)initWithVideoContainer:(id <BMVideoContainer>)theVideoContainer;

/**
 Initializer with the specified class which should be a class implementing BMVideoContainer.
 
 Upon tranform a new instance of this class is created.
 */
- (id)initWithVideoContainerClass:(Class<BMVideoContainer>)theClass;

/**
 Initializes with the specified block to construct a new BMViceoContainer upon transform.
 */
- (id)initWithVideoContainerConstructorBlock:(BMVideoContainerConstructorBlock)block;

@end

@interface BMYouTubeEntryTransformer(Protected)

/**
 Override to perform additional conversion.
 */
- (void)populateVideo:(id <BMVideoContainer>)video withMediaGroup:(GDataYouTubeMediaGroup *)mediaGroup;

@end
