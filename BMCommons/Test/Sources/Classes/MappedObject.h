//
//  MappedObject.h
//  BMCommons
//
//  Created by Werner Altewischer on 1/13/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAbstractMappableObject.h>

@interface MappedObject : BMAbstractMappableObject

@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, strong) NSMutableDictionary *objectValues;

@end
