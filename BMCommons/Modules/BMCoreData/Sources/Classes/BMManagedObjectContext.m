//
//  BMManagedObjectContext.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/17/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMManagedObjectContext.h>
#import <BMCommons/BMCore.h>

@implementation BMManagedObjectContext {
    NSMutableArray *delegates;
}

- (id)initWithConcurrencyType:(NSManagedObjectContextConcurrencyType)ct {
	if ((self = [super initWithConcurrencyType:ct])) {
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(managedObjectContextDidChange:)
		 name:NSManagedObjectContextObjectsDidChangeNotification
		 object:self];
        [[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(managedObjectContextDidSave:)
		 name:NSManagedObjectContextDidSaveNotification
		 object:self];
		delegates = BMCreateNonRetainingArray();
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	BM_RELEASE_SAFELY(delegates);
}

- (void)addDelegate:(id <BMManagedObjectContextDelegate>)delegate {
	if (![delegates bmContainsObjectIdenticalTo:delegate]) {
		[delegates addObject:delegate];
	}
}

- (void)removeDelegate:(id <BMManagedObjectContextDelegate>)delegate {
	[delegates removeObjectIdenticalTo:delegate];
}

- (void)managedObjectContextDidChange:(NSNotification *)notification {
	NSDictionary *userInfo = notification.userInfo;
	NSSet *deletedObjects = userInfo[NSDeletedObjectsKey];
	NSArray *theDelegates = [NSArray arrayWithArray:delegates];
	for (NSManagedObject *deletedObject in deletedObjects) {
		for (id <BMManagedObjectContextDelegate> delegate in theDelegates) {
			if ([delegate respondsToSelector:@selector(managedObjectContext:didDeleteObject:)]) {
				[delegate managedObjectContext:self didDeleteObject:deletedObject];
			}
		}
	}
	NSSet *insertedObjects = userInfo[NSInsertedObjectsKey];
	for (NSManagedObject *insertedObject in insertedObjects) {
		for (id <BMManagedObjectContextDelegate> delegate in theDelegates) {
			if ([delegate respondsToSelector:@selector(managedObjectContext:didInsertObject:)]) {
				[delegate managedObjectContext:self didInsertObject:insertedObject];
			}
		}
	}
	NSSet *updatedObjects = userInfo[NSUpdatedObjectsKey];
	for (NSManagedObject *updatedObject in updatedObjects) {
		for (id <BMManagedObjectContextDelegate> delegate in theDelegates) {
			if ([delegate respondsToSelector:@selector(managedObjectContext:didUpdateObject:)]) {
				[delegate managedObjectContext:self didUpdateObject:updatedObject];
			}
		}
	}
}

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    NSArray *theDelegates = [NSArray arrayWithArray:delegates];
    for (id <BMManagedObjectContextDelegate> delegate in theDelegates) {
        if ([delegate respondsToSelector:@selector(managedObjectContextDidSave:)]) {
            [delegate managedObjectContextDidSave:self];
        }
    }
}

@end
