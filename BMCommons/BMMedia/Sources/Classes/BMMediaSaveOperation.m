//
//  BMMediaSaveOperation.m
//  BMCommons
//
//  Created by Werner Altewischer on 23/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCore/BMCore.h>
#import <BMCommons/BMMediaSaveOperation.h>
#import <BMMedia/BMMedia.h>

@implementation BMMediaSaveOperation {
	id<BMMediaContainer> media;
}

@synthesize media;

- (id)initWithMedia:(id <BMMediaContainer>)theMedia {
	if ((self = [super init])) {
        BMMediaCheckLicense();
		media = theMedia;
		
	}
	return self;
}

- (void)dealloc {
	BM_RELEASE_SAFELY(media);
}

- (void)performOperation {
	
}

- (void)main {
	@autoreleasepool {
		[media addDelegate:self];
		@try {
			
			[self performOperation];
			
		} @catch (id exception) {
			//We have to catch exceptions because the MediaProcessingQueue might delete the video object upon termination. 
			//The app should not crash because of that.
			LogError(@"Media save job got exception: %@", exception);
		}
		LogInfo(@"Media save job finished: %@", self);
		[media removeDelegate:self];
	}
}


#pragma mark -
#pragma mark MediaContainerDelegate

- (void)mediaContainerDidUpdate:(id <BMMediaContainer>)mediaContainer {
	
}

- (void)mediaContainerWasDeleted:(id <BMMediaContainer>)mediaContainer {
	//Cancel the operation in case of deletion of the underlying media
	[self cancel];
}

@end
