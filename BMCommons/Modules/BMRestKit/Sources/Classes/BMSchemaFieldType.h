//
//  BMCommons
//
//  Created by Werner Altewischer on 17/09/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, BMSchemaFieldType) {
    BMSchemaFieldTypeNone = 0,
    BMSchemaFieldTypePrimitive = 1 << 0,
    BMSchemaFieldTypeArray = 1 << 1,
    BMSchemaFieldTypeObject = 1 << 2,
    BMSchemaFieldTypeObjectReference = 1 << 3,
    BMSchemaFieldTypeUnique = 1 << 4,
};

typedef NS_ENUM(NSUInteger, BMSchemaFieldFormatType) {
    BMSchemaFieldFormatTypeNone = 0,
    BMSchemaFieldFormatTypeURI = 1,
    BMSchemaFieldFormatTypeDateTime = 2,
    BMSchemaFieldFormatTypeEmailAddress = 3,
    BMSchemaFieldFormatTypeHostname = 4,
    BMSchemaFieldFormatTypeIPV4Address = 5,
    BMSchemaFieldFormatTypeIPV6Address = 6,
};
