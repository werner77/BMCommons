//
//  BMPrimitiveType.m
//  BMCommons
//
//  Created by Werner Altewischer on 18/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMValueType.h>
#import <BMCommons/NSObject+BMCommons.h>

@implementation BMValueTypeConverter

#define COPY_VALUE(type, source, dest) ({ type x = (source); memcpy (dest, (void *)&x, sizeof(type)); })

#define PRIMITIVE_FROM_VALUE(type, value) ({ type x; memcpy ((void *)&x, value, sizeof(type)); x; })

+ (BMValueTypeConverter *)converterForValueType:(BMValueType)valueType {
    BMValueTypeConverter *converter = [[BMValueTypeConverter alloc] initWithValueType:valueType];
    return converter;
}

- (id)init {
    return [self initWithValueType:BMValueTypeObject];
}

- (id)initWithValueType:(BMValueType)valueType {
    if (![self isValidValueType:valueType]) {
        return nil;
    }
    
    if ((self = [super init])) {
        _valueType = valueType;
    }
    return self;
}

- (BOOL)isValidValueType:(BMValueType)valueType {
    return valueType > 0 && valueType <= BMValueTypeDouble;
}

- (BOOL)getPrimitiveValue:(void *)value withLength:(NSUInteger)valueLength fromObjectValue:(id)objectValue {
    BOOL copied = NO;
    if (value != nil && valueLength == self.sizeOfPrimitiveValue) {
        copied = YES;
        NSNumber *numberValue = [objectValue bmCastSafely:[NSNumber class]];
        
        switch (self.valueType) {
            case BMValueTypeBoolean:
                COPY_VALUE(BOOL, [numberValue boolValue], value);
                break;
                
            case BMValueTypeInteger:
                COPY_VALUE(NSInteger, [numberValue integerValue], value);
                break;
                
            case BMValueTypeUnsignedInteger:
                COPY_VALUE(NSUInteger, [numberValue unsignedIntegerValue], value);
                break;
                
            case BMValueTypeFloat:
                COPY_VALUE(float, [numberValue floatValue], value);
                break;
                
            case BMValueTypeDouble:
                COPY_VALUE(double, [numberValue doubleValue], value);
                break;
              
            case BMValueTypeObject:
                COPY_VALUE(id, objectValue, value);
                break;
            default:
                copied = NO;
                break;
        }
    }
    return copied;
}

- (id)objectValueFromPrimitiveValue:(void *)value withLength:(NSUInteger)valueLength {
    id ret = nil;
    if (value && self.sizeOfPrimitiveValue == valueLength) {
        switch (self.valueType) {
            case BMValueTypeBoolean:
                ret = [NSNumber numberWithBool:PRIMITIVE_FROM_VALUE(BOOL, value)];
                break;
                
            case BMValueTypeInteger:
                ret = [NSNumber numberWithInteger:PRIMITIVE_FROM_VALUE(NSInteger, value)];
                break;
                
            case BMValueTypeUnsignedInteger:
                ret = [NSNumber numberWithUnsignedInteger:PRIMITIVE_FROM_VALUE(NSUInteger, value)];
                break;
                
            case BMValueTypeFloat:
                ret = [NSNumber numberWithFloat:PRIMITIVE_FROM_VALUE(float, value)];
                break;
                
            case BMValueTypeDouble:
                ret = [NSNumber numberWithDouble:PRIMITIVE_FROM_VALUE(double, value)];
                break;
            
            case BMValueTypeObject:
                ret = PRIMITIVE_FROM_VALUE(id, value);
                break;
                
            default:
                break;
        }
    }
    
    return ret;
}

- (NSUInteger)sizeOfPrimitiveValue {
    NSUInteger size = 0;
    switch (self.valueType) {
        case BMValueTypeBoolean:
            size = sizeof(BOOL);
            break;
            
        case BMValueTypeInteger:
            size = sizeof(NSInteger);
            break;
            
        case BMValueTypeUnsignedInteger:
            size = sizeof(NSUInteger);
            break;
            
        case BMValueTypeFloat:
            size = sizeof(float);
            break;
            
        case BMValueTypeDouble:
            size = sizeof(double);
            break;
            
        case BMValueTypeObject:
            size = sizeof(id);
            break;
            
        default:
            break;
    }
    return size;
}

@end
