//
//  BMManagedObjectContext.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/17/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <BMCoreData/BMRootManagedObject.h>

@class BMManagedObjectContext;

@protocol BMManagedObjectContextDelegate<NSObject>

@optional
- (void)managedObjectContext:(BMManagedObjectContext *)objectContext didInsertObject:(NSManagedObject *)object;
- (void)managedObjectContext:(BMManagedObjectContext *)objectContext didDeleteObject:(NSManagedObject *)object;
- (void)managedObjectContext:(BMManagedObjectContext *)objectContext didUpdateObject:(NSManagedObject *)object;
- (void)managedObjectContextDidSave:(BMManagedObjectContext *)objectContext;

@end

/**
 Extension of NSManagedObjectContext that adds support for delegates of object inserts, updates and deletes.
 */
@interface BMManagedObjectContext : NSManagedObjectContext 

- (void)addDelegate:(id <BMManagedObjectContextDelegate>)delegate;
- (void)removeDelegate:(id <BMManagedObjectContextDelegate>)delegate;

@end
