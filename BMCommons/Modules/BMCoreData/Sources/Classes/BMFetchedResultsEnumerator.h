//
//  BMFetchedResultsEnumerator.h
//  BMCommons
//
//  Created by Werner Altewischer on 11/08/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Enumerator to enumerate over the results of a fetched results controller.
 */
@interface BMFetchedResultsEnumerator : NSEnumerator

- (id)initWithResultsController:(NSFetchedResultsController *)resultsController;
- (NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
