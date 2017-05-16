//
//  BMTwoWayDictionary.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/10/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreObject.h>

/**
 Dictionary that allows two-way access, i.e. also allows getting a key for an object as well as an object for a key.
 
 This is handy for two-way look up tables.
 */
@interface BMTwoWayDictionary : BMCoreObject {
    @private
	NSDictionary *forwardDictionary;
	NSDictionary *reverseDictionary;
	BOOL localizeValues;
	BOOL localizeKeys;
}

/**
 Whether to localize the value when the value is a string (that is put NSLocalizedString around it)
 */
@property(nonatomic, assign) BOOL localizeValues;

/**
 Whether to localize the key when the key is a string (that is put NSLocalizedString around it)
 */
@property(nonatomic, assign) BOOL localizeKeys;


+ (id)dictionaryWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

+ (id)dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;
- (id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;

+ (id)dictionaryWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;

- (id)objectForKey:(id)aKey;

/**
 Gets an object for the specified key
 
 @param object The object
 @return the key for the object
 */
- (id)keyForObject:(id)object;

- (NSArray *)allKeys;
- (NSArray *)allValues;

@end
