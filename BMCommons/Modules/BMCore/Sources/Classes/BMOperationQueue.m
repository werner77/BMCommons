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

@implementation BMOperationQueue {
	NSInteger _busyThreshold;
	NSMutableArray *_delegates;
}

BM_SYNTHESIZE_DEFAULT_SINGLETON

- (id)init {
	if (self = [super init]) {
		_processingQueue = [NSOperationQueue new];
		_processingQueue.maxConcurrentOperationCount = 3;
		_busyThreshold = 1;
		_delegates = BMCreateNonRetainingArray();
	}
	return self;
}

- (void)addDelegate:(id <BMOperationQueueDelegate>)delegate {
	if (![_delegates bmContainsObjectIdenticalTo:delegate]) {
		[_delegates addObject:delegate];
	}
}

- (void)removeDelegate:(id <BMOperationQueueDelegate>)delegate {
	[_delegates removeObjectIdenticalTo:delegate];
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
	return _processingQueue.operations.count > _busyThreshold;
}

- (void)waitUntilReady {
	while (_processingQueue.operations.count > _busyThreshold) {
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
	}
}

- (void)terminate {
	[_processingQueue cancelAllOperations];
}


@end

@implementation BMOperationQueue(Private)

- (void)startOperation:(NSOperation *)operation {
	[operation addObserver:self forKeyPath:FINISHED_KEYPATH 
				   options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
				   context:NULL];
	[_processingQueue addOperation:operation];
}

- (void)finishOperation:(NSOperation *)operation {
	[operation removeObserver:self forKeyPath:FINISHED_KEYPATH];
	for (id <BMOperationQueueDelegate> delegate in [NSArray arrayWithArray:_delegates]) {
		[delegate operationQueue:self didFinishOperation:operation];
	}
}

@end
