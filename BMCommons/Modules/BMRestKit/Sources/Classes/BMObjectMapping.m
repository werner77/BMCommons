//
//  BMObjectMapping.m
//  BMCommons
//
//  Created by Werner Altewischer on 2/9/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMObjectMapping.h>
#import <BMCommons/BMAbstractMappableObject.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMRestKit.h>
#import "NSString+BMCommons.h"

@implementation BMObjectMapping {
@private
    NSMutableArray *_fieldMappings;
    NSMutableArray *_enumeratedValues;
}

@synthesize name = _name, namespaceURI = _namespaceURI, parentName = _parentName, elementName = _elementName, rootElement = _rootElement;

- (id)init {
	return [self initWithName:@""];
}

- (id)initWithName:(NSString *)theName {
    if ((self = [super init])) {
        _name = theName;
        _fieldMappings = [NSMutableArray new];
        _enumeratedValues = [NSMutableArray new];
    }
    return self;
}

- (void)addFieldMapping:(BMFieldMapping *)fm {
	[_fieldMappings addObject:fm];
    fm.parentObjectMapping = self;
}

- (void)removeFieldMapping:(BMFieldMapping *)fm {
    [_fieldMappings removeObject:fm];
    fm.parentObjectMapping = nil;
}

- (void)addEnumeratedValue:(BMEnumerationValue *)value {
	if (![_enumeratedValues containsObject:value]) {
		[_enumeratedValues addObject:value];
	}
}

- (BOOL)isEnumeration {
	return _enumeratedValues.count > 0;
}

- (BMFieldMapping *)enumeratedFieldValueMapping {
    BMFieldMapping *ret = nil;
    if (self.isEnumeration) {
        ret = [self.fieldMappings bmFirstObjectWithPredicate:^BOOL(BMFieldMapping* fm) {
            return [fm.fieldName isEqualToString:@"value"];
        }];
    }
    return ret;
}

- (NSArray *)fieldMappings {
	return [NSArray arrayWithArray:_fieldMappings];
}

- (NSArray *)enumeratedValues {
	return [NSArray arrayWithArray:_enumeratedValues];
}

- (NSString *)fqElementName {
    if ([BMStringHelper isEmpty:self.namespaceURI] || [BMStringHelper isEmpty:self.elementName]) {
        return self.elementName;
    } else {
        if ([self.namespaceURI hasSuffix:@":"]) {
            return [self.namespaceURI stringByAppendingString:self.elementName];
        } else {
            return [NSString stringWithFormat:@"%@:%@", self.namespaceURI, self.elementName];
        }
    }
}

- (NSString *)objectClassName {
    return self.name;
}

- (NSString *)unqualifiedObjectClassName {
    return [self.name bmStringByCroppingUptoLastOccurenceOfString:@"."];
}
    
- (NSString *)parentObjectClassName {
    return self.parentName;
}
    
- (NSString *)unqualifiedParentObjectClassName {
    return [self.parentName bmStringByCroppingUptoLastOccurenceOfString:@"."];
}

- (NSArray *)inheritedFieldMappings {
    NSMutableArray *ret = [NSMutableArray new];
    BMObjectMapping *parent = self.parentMapping;
    while (parent != nil) {
        [ret addObjectsFromArray:parent.fieldMappings];
        parent = parent.parentMapping;
    }
    return ret;
}

- (NSArray *)allFieldMappings {
    NSMutableArray *ret = [NSMutableArray new];
    [ret addObjectsFromArray:self.fieldMappings];
    [ret addObjectsFromArray:self.inheritedFieldMappings];
    return ret;
}

@end

