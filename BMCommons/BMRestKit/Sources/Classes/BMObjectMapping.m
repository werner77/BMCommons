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

@implementation BMObjectMapping

@synthesize name, namespaceURI, parentName, elementName, rootElement, enumerationValues;

- (id)init {
	if ((self = [super init])) {

		fieldMappings = [NSMutableArray new];
		enumerationValues = [NSMutableArray new];
	}
	return self;
}


- (void)addFieldMapping:(BMFieldMapping *)fm {
	[fieldMappings addObject:fm];
}

- (void)removeFieldMapping:(BMFieldMapping *)fm {
    [fieldMappings removeObject:fm];
}

- (void)addEnumerationValue:(BMEnumerationValue *)value {
	if (![enumerationValues containsObject:value]) {
		[enumerationValues addObject:value];
	}
}

- (BOOL)isEnumeration {
	return enumerationValues.count > 0;
}

- (NSArray *)fieldMappings {
	return [NSArray arrayWithArray:fieldMappings];
}

- (NSArray *)enumeratedValues {
	return [NSArray arrayWithArray:enumerationValues];
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

- (NSString *)className {
    return self.name;
}

@end

