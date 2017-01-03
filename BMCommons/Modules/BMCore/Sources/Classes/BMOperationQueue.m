//
//  BMOperationQueue.m
//  BMCommons
//
//  Created by Werner Altewischer on 3/3/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMOperationQueue.h>
#import <BMCommons/BMCore.h>

#define FINISHED_KEYPATH @"isFinished"

@interface BMOperationQueue(Private)

- (void)startOperation:(NSOperation *)operation;
- (void)finishOperation:(NSOperation *)operation;

@end

@implementation BMOperationQueue

@synthesize processingQueue;

BM_SYNTHESIZE_DEFAULT_SINGLETON

- (id)init {
	if (self = [super init]) {
		processingQueue = [NSOperationQueue new];
		processingQueue.maxConcurrentOperationCount = 3;
		busyThreshold = 1;
		delegates = BMCreateNonRetainingArray();
	}
	return self;
}

- (void)addDelegate:(id <BMOperationQueueDelegate>)delegate {
	if (![delegates bmContainsObjectIdenticalTo:delegate]) {
		[delegates addObject:delegate];
	}
}

- (void)removeDelegate:(id <BMOperationQueueDelegate>)delegate {
	[delegates removeObjectIdenticalTo:delegate];
}

- (void)scheduleOperation:(NSOperation *)operation {
	[self startOperation:operation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
	NSOperation *operation = (NSOperation *)object;
	if ([keyPath isEqualToString:FINISHED_KEYPATH]) {
		if ([operation isFinished] && ![operation isCancelled]) {
			[self performSelectorOnMainThread:@selector(finishOperation:) withObject:operation waitUntilDone:NO];
		}
	}
}

- (BOOL)isBusy {
	return processingQueue.operations.count > busyThreshold;
}

- (void)waitUntilReady {
	while (processingQueue.operations.count > busyThreshold) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
}

- (void)terminate {
	[processingQueue cancelAllOperations];
}


@end

@implementation BMOperationQueue(Private)

- (void)startOperation:(NSOperation *)operation {
	[operation addObserver:self forKeyPath:FINISHED_KEYPATH 
				   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
				   context:NULL];
	[processingQueue addOperation:operation];
}

- (void)finishOperation:(NSOperation *)operation {
	[operation removeObserver:self forKeyPath:FINISHED_KEYPATH];
	for (id <BMOperationQueueDelegate> delegate in [NSArray arrayWithArray:delegates]) {
		[delegate operationQueue:self didFinishOperation:operation];
	}
}

@end
