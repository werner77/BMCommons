//
//  MappedObject.m
//  BMCommons
//
//  Created by Werner Altewischer on 1/13/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import "MappedObject.h"
#import <BMCommons/BMOrderedDictionary.h>

@implementation MappedObject

+ (NSArray *)fieldMappingFormatArray {
    NSMutableArray *mappings = [NSMutableArray array];
	
    [mappings addObject:@"values;values;dictionary(int)"];
    [mappings addObject:@"objectValues;objectValues;dictionary(MappedObject)"];
    
	return mappings;
}

- (id)init {
    if ((self = [super init])) {
        self.values = [BMOrderedDictionary new];
        self.objectValues = [BMOrderedDictionary new];
    }
    return self;
}

@end
