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
    NSMutableArray *_enumerationValues;
}

@synthesize name = _name, namespaceURI = _namespaceURI, parentName = _parentName, elementName = _elementName, rootElement = _rootElement;

- (id)init {
	return [self initWithName:@""];
}

- (id)initWithName:(NSString *)theName {
    if ((self = [super init])) {
        _name = theName;
        _fieldMappings = [NSMutableArray new];
        _enumerationValues = [NSMutableArray new];
    }
    return self;
}

- (void)addFieldMapping:(BMFieldMapping *)fm {
	[_fieldMappings addObject:fm];
}

- (void)removeFieldMapping:(BMFieldMapping *)fm {
    [_fieldMappings removeObject:fm];
}

- (void)addEnumerationValue:(BMEnumerationValue *)value {
	if (![_enumerationValues containsObject:value]) {
		[_enumerationValues addObject:value];
	}
}

- (BOOL)isEnumeration {
	return _enumerationValues.count > 0;
}

- (NSArray *)fieldMappings {
	return [NSArray arrayWithArray:_fieldMappings];
}

- (NSArray *)enumerationValues {
	return [NSArray arrayWithArray:_enumerationValues];
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

@end

