//
//  BMFetchedResultsEnumerator.h
//  BMCommons
//
//  Created by Werner Altewischer on 11/08/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 Enumerator to enumerate over the results of a fetched results controller.
 */
@interface BMFetchedResultsEnumerator : NSEnumerator {
	NSFetchedResultsController *resultsController;
	NSUInteger counter;
	NSUInteger count;
}

- (id)initWithResultsController:(NSFetchedResultsController *)resultsController;
- (NSUInteger)count;

@end
