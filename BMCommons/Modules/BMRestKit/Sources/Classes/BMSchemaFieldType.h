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

