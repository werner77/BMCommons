//
//  BMFetchedResultsEnumerator.m
//  BMCommons
//
//  Created by Werner Altewischer on 11/08/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMFetchedResultsEnumerator.h>

@implementation BMFetchedResultsEnumerator {
	NSFetchedResultsController *resultsController;
	NSUInteger counter;
	NSUInteger count;
}

- (id)initWithResultsController:(NSFetchedResultsController *)rc {
	if ((self = [super init])) {
		resultsController = rc;
		counter = 0;
		count = NSNotFound;
	} 
	return self;
}

- (NSUInteger)count {
	if (count == NSNotFound) {
		NSArray *sections = [resultsController sections];
		count = 0;
		if ([sections count]) {
			id <NSFetchedResultsSectionInfo> sectionInfo = sections[0];
			count = [sectionInfo numberOfObjects];
		}
	}
    return count;
}

- (id)nextObject {
	if (counter >= [self count]) return nil;
	
	NSUInteger indexes[] = {
		0, counter++
	};
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	return [resultsController objectAtIndexPath:indexPath];
}


@end
