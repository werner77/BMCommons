//
//  BMAlphabeticListTableViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 14/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMEntityServiceModelTableViewController.h>
#import <BMCommons/BMNamedObject.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMAlphabeticListTableViewController : BMEntityServiceModelTableViewController

@property (nullable, nonatomic, readonly) NSDictionary *allObjects;
@property (nullable, nonatomic, readonly) NSDictionary *searchedObjects;
@property (nonatomic, assign, getter=isSummaryCellEnabled) BOOL summaryCellEnabled;

//Methods to be implemented by sub classes

/**
  * Action to perform when the row for the supplied object has been selected.
  */
- (void)didSelectRowForObject:(id<BMNamedObject>)object;

/**
  * The summary cell (to be displayed at the bottom of the table)
  */
- (nullable UITableViewCell *)summaryCellForCount:(NSUInteger)count;

/**
  * Cell for the specified object
  */
- (UITableViewCell *)cellForObject:(id<BMNamedObject>)object;

@end

NS_ASSUME_NONNULL_END
