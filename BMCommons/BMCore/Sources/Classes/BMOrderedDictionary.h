//
//  BMOrderedDictionary.h
//  BMCommons
//
//  Created by Werner Altewischer on 08/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <BMCore/BMAbstractMutableDictionary.h>

/**
 Dictionary which retains the insertion order and allows objects to be inserted at specified indexes.
 */
@interface BMOrderedDictionary : BMAbstractMutableDictionary

/**
 Inserts object for key at the specified index
 
 @param anObject the object to insert
 @param aKey the key to use
 @param anIndex the index
 */
- (void)insertObject:(id)anObject forKey:(id)aKey atIndex:(NSUInteger)anIndex;

/**
 Moves the specified object to a specified index.
 
 Only works if the key already exists in the dictionary.
 
 Returns YES if successful, no otherwise
 */
- (BOOL)moveObjectForKey:(id)aKey toIndex:(NSUInteger)toIndex;

- (void)moveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end
