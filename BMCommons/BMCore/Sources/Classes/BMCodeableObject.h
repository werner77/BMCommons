//
//  BMCodeableObject.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCore/BMCoreObject.h>

/**
 Class that implements the NSCoding protocol in a dynamic way using BMPropertyDescriptors which properties to code for this class.
 */
@interface BMCodeableObject : BMCoreObject<NSCoding>

/**
 Returns an array of BMPropertyDescriptor instances describing the properties which should be coded using keyed archiving.
 
 Should be implemented by sub classes.
 */
+ (NSArray *)descriptorsForCodeableProperties;

/**
 Object constructed from the specified data.
 
 Returns nil if the data is not compatible.
 */
+ (instancetype)objectFromArchivedData:(NSData *)data;

/**
 Archived data by archiving this object using a keyed archiver.
 */
- (NSData *)archivedData;

@end
