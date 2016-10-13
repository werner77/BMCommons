//
//  BMParserElement.m
//  BMCommons
//
//  Created by Werner Altewischer on 10/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import "BMParserElement.h"
#import "BMXPathQuery.h"
#import "BMStringHelper.h"
#import "BMKeyValuePair.h"
#import <BMCommons/BMRestKit.h>

@interface BMParserElement(Private)

- (NSString *)fieldKeyForAttributeName:(NSString *)attributeName andFullElementName:(NSString *)fullElementName;
- (NSString *)elementNameRelativeToModelObject:(NSObject<BMMappableObject> **)theModelObject fieldMappings:(NSDictionary **)theFieldMappings;
- (void)appendXMLToString:(NSMutableString *)s;

@end

@implementation BMParserElement

@synthesize elementName;
@synthesize attributes;
@synthesize parentElement;
@synthesize modelObject;
@synthesize fieldMappings;
@synthesize context;
@synthesize nilElement;
@synthesize treatAttributesAsElements;

- (id)init {
    if ((self = [super init])) {
        BMRestKitCheckLicense();
    }
    return self;
}

- (id)initWithName:(NSString *)theElementName attributes:(NSDictionary *)theAttributes parent:(BMParserElement *)theParent {
	if ((self = [super init])) {
        BMRestKitCheckLicense();
		elementName = theElementName;
		attributes = theAttributes;
		parentElement = theParent;
	}
	return self;
}

- (void)setModelObject:(NSObject <BMMappableObject> *)theModelObject {
	if (modelObject != theModelObject) {
		modelObject = theModelObject;
	}
	
	NSDictionary *theFieldMappings = [[theModelObject class] fieldMappings];
	if (fieldMappings != theFieldMappings) {
		fieldMappings = theFieldMappings;
	}
}
    
- (BMFieldMapping *)dictionaryFieldMappingFromMappings:(NSDictionary *)theMappings withElementName:(NSString *)theElementName key:(NSString **)key {
    BMFieldMapping *fieldMapping = nil;
    NSString *parentElementName = nil;
    NSString *theKey = nil;
    if (theElementName) {
        //Try and see if this is a dictionary mapping
        NSRange range = [theElementName rangeOfString:MAPPING_ELEMENT_SEPARATOR options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            parentElementName = [theElementName substringToIndex:range.location];
            theKey = [theElementName substringFromIndex:range.location + 1];
        }
    }
    fieldMapping = [theMappings objectForKey:parentElementName];
    
    if (!fieldMapping.isDictionary) {
        fieldMapping = nil;
        theKey = nil;
    }
    
    if (key) {
        *key = theKey;
    }
    return fieldMapping;
}

- (BMFieldMapping *)fieldMappingFromDictionary:(NSDictionary *)theMappings key:(NSString *)theElementName text:(NSString *)theElementText value:(id *)theValue {
    
    BMFieldMapping *fieldMapping = [theMappings objectForKey:(theElementName == nil ? @"" : theElementName)];
    
    id v = nil;
    
    if (fieldMapping == nil) {
        
        NSString *key = nil;
        fieldMapping = [self dictionaryFieldMappingFromMappings:theMappings withElementName:theElementName key:&key];
        
        if (fieldMapping) {
            BMKeyValuePair *keyValuePair = [BMKeyValuePair new];
            keyValuePair.key = key;
            keyValuePair.value = theElementText;
            v = keyValuePair;
        }
        
    } else {
        v = theElementText;
    }
    
    if (theValue) {
        *theValue = v;
    }
    return fieldMapping;
}

- (void)fillModelObject {
    NSString *elementText = self.elementText;
	NSDictionary *currentAttributes = self.attributes;
	NSDictionary *theMappings = nil;
	NSObject<BMMappableObject> *theModelObject = nil;
	NSString *fullElementName = [self elementNameRelativeToModelObject:&theModelObject fieldMappings:&theMappings];
		
	if (theModelObject) {
		BMFieldMapping *fieldMapping; 
		for (NSString *attributeName in currentAttributes) {
			NSString *fieldKey = [self fieldKeyForAttributeName:attributeName andFullElementName:fullElementName];
			fieldMapping = [theMappings objectForKey:fieldKey];
			if (fieldMapping) {
				[fieldMapping invokeSetterOnTarget:theModelObject withValue:[currentAttributes objectForKey:attributeName]];
			}
		}
		
        id theValue = nil;
        fieldMapping = [self fieldMappingFromDictionary:theMappings key:fullElementName text:elementText value:&theValue];
		if (fieldMapping) {
			[fieldMapping invokeSetterOnTarget:theModelObject withValue:theValue];
		} else if (self.treatAttributesAsElements) {
            //No field mapping found as element, try attribute mapping of parent
            NSDictionary *parentMappings = nil;
            NSObject<BMMappableObject> *parentModelObject = nil;
            BMParserElement *theParentElement = self.parentElement;
            NSString *parentFullElementName = [theParentElement elementNameRelativeToModelObject:&parentModelObject fieldMappings:&parentMappings];
            if (parentModelObject) {
                NSString *fieldKey = [theParentElement fieldKeyForAttributeName:self.elementName andFullElementName:parentFullElementName];
                
                fieldMapping = [self fieldMappingFromDictionary:parentMappings key:fieldKey text:elementText value:&theValue];
                if (fieldMapping) {
                    [fieldMapping invokeSetterOnTarget:parentModelObject withValue:elementText];
                }
            }
        }
		
		if (!fullElementName && self.parentElement != nil) {
			//root element for this model object: check whether parent model object contains array type of this modelobject's type.
			//If yes then add it to the array
			NSObject<BMMappableObject> *parentModelObject = nil;
			NSDictionary *parentFieldMappings = nil;
			NSString *parentFullElementName = [self.parentElement elementNameRelativeToModelObject:&parentModelObject 
																					 fieldMappings:&parentFieldMappings];
			
			if (parentModelObject != nil) {
				NSString *fullElementNameRelativeToParent = parentFullElementName ? 
				[NSString stringWithFormat:@"%@" MAPPING_ELEMENT_SEPARATOR @"%@", parentFullElementName, self.elementName] : self.elementName;
				
				fieldMapping = [parentFieldMappings objectForKey:fullElementNameRelativeToParent];
				if (fieldMapping) {
					[fieldMapping invokeSetterOnTarget:parentModelObject withValue:theModelObject];
				} else {
                    //Check dictionary mapping
                    NSString *key = nil;
                    fieldMapping = [self dictionaryFieldMappingFromMappings:theMappings withElementName:fullElementNameRelativeToParent key:&key];
                    if (fieldMapping) {
                        BMKeyValuePair *keyValuePair = [BMKeyValuePair new];
                        keyValuePair.key = key;
                        keyValuePair.value = theModelObject;
                        [fieldMapping invokeSetterOnTarget:parentModelObject withValue:keyValuePair];
                    }
                }
			}
		}	
	}
}

- (void)appendText:(NSString *)text {
    if (!buffer) {
        buffer = [[NSMutableString alloc] initWithCapacity:text.length];
    }
    [buffer appendString:text];
}

- (NSString *)elementText {
    return buffer ? buffer : @"";
}

- (NSString *)xmlString {
	NSMutableString *s = [NSMutableString stringWithCapacity:256];
	[self appendXMLToString:s];
	return s;
}

- (BOOL)matchesXPath:(NSString *)xpath {
	NSString *xmlString = self.xmlString;
	BMXPathQuery *xpathQuery = [[BMXPathQuery alloc] initWithXMLDocument:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
	NSArray *results = [xpathQuery performXPathQuery:xpath];
	return results.count > 0;
}

@end

@implementation BMParserElement(Private)

- (NSString *)fieldKeyForAttributeName:(NSString *)attributeName andFullElementName:(NSString *)fullElementName {
    NSString *fieldKey;
    if (fullElementName == nil) {
        fieldKey = [NSString stringWithFormat:MAPPING_ATTRIBUTE_SEPARATOR @"%@", attributeName];
    } else {
        fieldKey = [NSString stringWithFormat:@"%@" MAPPING_ATTRIBUTE_SEPARATOR @"%@", fullElementName, attributeName];
    }
    return fieldKey;
}
		   
- (void)appendXMLToString:(NSMutableString *)s {
	
	NSMutableString *before = [[NSMutableString alloc] initWithCapacity:64];
	
	[before appendString:@"<"];
	[before appendString:self.elementName];
	
	NSDictionary *theAttributes = self.attributes;
	
	for (NSString *attributeName in theAttributes) {
		[before appendString:@" "];
		[before appendString:attributeName];
		[before appendString:@"=\""];
		NSString *attributeValue = [[theAttributes objectForKey:attributeName] description];
		[before appendString:[BMStringHelper filterNilString:attributeValue]];
		[before appendString:@"\""];
	}
	[before appendString:@">"];
	
	[s insertString:before atIndex:0];
	
	
	[s appendString:@"</"];
	[s appendString:self.elementName];
	[s appendString:@">"];
	
	[self.parentElement appendXMLToString:s];
}
		   

- (NSString *)elementNameRelativeToModelObject:(NSObject<BMMappableObject> **)theModelObject fieldMappings:(NSDictionary **)theFieldMappings {
	NSString *theElementName = nil;
	
	BMParserElement *theElement = self;
	
	while (theElement.modelObject == nil) {
		if (theElement == nil) {
			//No model object found
			return theElementName;
		}
		if (theElementName == nil) {
			theElementName = theElement.elementName;
		} else {
			theElementName = [NSString stringWithFormat:@"%@" MAPPING_ELEMENT_SEPARATOR @"%@", theElement.elementName, theElementName];
		}
		theElement = theElement.parentElement;
	}
    if (theModelObject) {
        *theModelObject = theElement.modelObject;
    }
	if (theFieldMappings) {
        *theFieldMappings = theElement.fieldMappings;
    }
	return theElementName;
}

@end
