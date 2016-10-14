//
//  BMMediaSaveOperation.h
//  BMCommons
//
//  Created by Werner Altewischer on 23/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaContainer.h>

/**
 NSOperation to save a BMMediaContainer instance.
 
 This is an abstract class meant to be sub-classed. Sub-classes should override the method performOperation. The operation is meant to be run in an NSOperationQueue for asynchronous processing.
 */
@interface BMMediaSaveOperation : NSOperation<BMMediaContainerDelegate>

/**
 The media container.
 */
@property (readonly) id<BMMediaContainer> media;

/**
 Initializer.
 */
- (id)initWithMedia:(id <BMMediaContainer>)theMedia;

/**
 Performs the actual operation. 
 
 Sub-classes should override this.
 */
- (void)performOperation;

@end
