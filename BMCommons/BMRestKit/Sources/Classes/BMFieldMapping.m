//
//  BMFieldMapping.m
//  BMCommons
//
//  Created by Werner Altewischer on 11/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <BMCommons/BMFieldMapping.h>
#import <BMCommons/BMNumberHelper.h>
#import <BMCommons/BMDateHelper.h>
#import "NSDateFormatter+BMCommons.h"
#import <BMCommons/BMOrderedDictionary.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMValueTransformer.h>
#import "NSString+BMCommons.h"
#import <BMCommons/BMRegexKitLite.h>
#import <BMCommons/BMRestKit.h>
#import <BMCommons/BMKeyValuePair.h>
#import <BMCommons/NSNumber+BMCommons.h>
#import <BMCommons/BMErrorHelper.h>

@interface BMFieldMapping(Private)

- (void)initSelectorFromFieldName:(NSString *)fieldName andType:(NSString *)type andFormat:(NSString *)format;
- (void)initConverterWithType:(NSString *)type subType:(NSString *)subType andFormat:(NSString *)format;
- (void)setConverterTarget:(id)target;
- (void)setInverseConverterTarget:(id)target;

@end

@implementation BMFieldMapping {
@private
    NSString *fieldName;
    NSString *fieldFormat;
    NSString *namespaceURI;
    
    NSArray *elementNameComponents;
    NSString *attributeName;
    NSString *mappingPath;
    
    SEL setterSelector;
    SEL getterSelector;
    SEL converterSelector;
    id converterTarget;
    SEL inverseConverterSelector;
    id inverseConverterTarget;
    BOOL array;
    BOOL set;
    BOOL dictionary;
    BOOL date;
    Class fieldObjectClass;
    NSString *fieldObjectClassName;
}

static BOOL classChecksEnabled = YES;
static NSString *defaultDateFormat = nil;
static NSTimeZone *defaultTimeZone = nil;

@synthesize namespaceURI;
@synthesize fieldName;
@synthesize setterSelector;
@synthesize converterSelector;
@synthesize converterTarget;
@synthesize inverseConverterTarget;
@synthesize inverseConverterSelector;
@synthesize getterSelector;
@synthesize array, elementNameComponents, attributeName, mappingPath, fieldObjectClass, date, dictionary, set;

+ (void)setClassChecksEnabled:(BOOL)enabled {
    classChecksEnabled = enabled;
}

+ (BOOL)isClassChecksEnabled {
    return classChecksEnabled;
}

+ (void)setDefaultDateFormat:(NSString *)dateFormat {
    if (dateFormat != defaultDateFormat) {
        defaultDateFormat = dateFormat;
    }
}

+ (NSString *)defaultDateFormat {
    return defaultDateFormat;
}

+ (void)setDefaultTimeZone:(NSTimeZone *)tz {
    if (tz != defaultTimeZone) {
        defaultTimeZone = tz;
    }
}

+ (NSTimeZone *)defaultTimeZone {
    return defaultTimeZone;
}

+ (NSDictionary *)parseFieldDescriptorDictionary:(NSDictionary *)dict {
	return [self parseFieldDescriptorDictionary:dict withNamespaces:nil];
}

+ (void)initialize {
    if (!defaultDateFormat) {
        [self setDefaultDateFormat:@"RFC3339"];
    }
    if (!defaultTimeZone) {
        [self setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }

}

+ (NSDictionary *)parseFieldDescriptorDictionary:(NSDictionary *)dict withNamespaces:(NSDictionary *)namespaceDict {
	NSMutableDictionary *ret = [[BMOrderedDictionary alloc] initWithCapacity:dict.count];
	for (NSString *key in dict) {
		NSString *fieldDescriptor = [dict objectForKey:key];
		BMFieldMapping *fieldMapping = [[BMFieldMapping alloc] initWithFieldDescriptor:fieldDescriptor mappingPath:key];
		if (fieldMapping != nil) {
			fieldMapping.namespaceURI = [namespaceDict objectForKey:key];
			[ret setObject:fieldMapping forKey:key];
		} else {
			NSException *ex = [NSException exceptionWithName:@"InvalidFieldMappingException" 
													  reason:[NSString stringWithFormat:@"Warning: Could not parse field descriptor '%@' for key '%@'", fieldDescriptor, key]
													userInfo:nil];
			@throw ex;
		}
	}
	return ret;
}

- (id)init {
    if ((self = [super init])) {

    }
    return self;
}

- (id)initWithFieldDescriptor:(NSString *)fieldDescriptor mappingPath:(NSString *)theMappingPath {
	if ((self = [super init])) {

        NSError *error;
        if (![self setFieldDescriptor:fieldDescriptor withError:&error]) {
            LogWarn(@"Could not initialize from the specified fieldDescriptor: %@: %@", fieldDescriptor, error);
            return nil;
        }
		[self setMappingPath:theMappingPath];
	}
	return self;
}

- (BOOL)setFieldDescriptor:(NSString *)fieldDescriptor withError:(NSError **)error {
    NSRange range;
    NSMutableArray *fieldComponents = [NSMutableArray arrayWithCapacity:3];
    NSString *currentComponent;
    NSUInteger startLocation = 0;
    while (startLocation < fieldDescriptor.length) {
        range = [fieldDescriptor rangeOfRegex:@"([^\\\\]:)|(^:)" inRange:NSMakeRange(startLocation, fieldDescriptor.length - startLocation)];
        if (range.location == NSNotFound) {
            range.location = fieldDescriptor.length + 1;
            range.length = 0;
        }
        currentComponent = [fieldDescriptor substringWithRange:NSMakeRange(startLocation, range.location + range.length - 1 - startLocation)];
        
        if (fieldComponents.count > 0) {
            if (fieldFormat) {
                fieldFormat = [fieldFormat stringByAppendingFormat:@":%@", currentComponent];
            } else {
                fieldFormat = currentComponent;
            }
        }
        currentComponent = [currentComponent  stringByReplacingOccurrencesOfString:@"\\:" withString:@":"];
        [fieldComponents addObject:currentComponent];
        startLocation = range.location + range.length;
    }
    
    if (fieldComponents.count == 0) {
        if (error) {
            *error = [BMErrorHelper genericErrorWithDescription:@"No field components found"];
        }
        return NO;
    }
    
    fieldName = [fieldComponents objectAtIndex:0];
    
    NSString *type = nil;
    NSString *subType = nil;
    NSString *format = nil;
    if (fieldComponents.count > 1) {
        type = [fieldComponents objectAtIndex:1];
        
        if (type) {
            NSRange range1 = [type rangeOfString:@"("];
            NSRange range2 = [type rangeOfString:@")"];
            if (range1.location != NSNotFound && range2.location != NSNotFound && range1.location < range2.location) {
                subType = [type substringWithRange:NSMakeRange(range1.location + 1, range2.location - range1.location - 1)];
                type = [type substringToIndex:range1.location];
            } else {
                subType = type;
            }
        }
        
        format = nil;
        if (fieldComponents.count > 2) {
            format = [fieldComponents objectAtIndex:2];
        }
    }

    [self initSelectorFromFieldName:fieldName andType:type andFormat:format];
    if (!self.setterSelector) {
        if (error) {
            *error = [BMErrorHelper genericErrorWithDescription:@"Could not determine setter selector"];
        }
        return NO;
    }
    
    //Default class is NSString
    fieldObjectClass = [NSString class];
    BM_RELEASE_SAFELY(fieldObjectClassName);
    if (type && subType) {
        [self initConverterWithType:type subType:subType andFormat:format];
    }
    _initialized = YES;
    return YES;
}

- (void)invokeSetterOnTarget:(NSObject <BMMappableObject> *)target withValue:(NSObject *)value {
    
    BMKeyValuePair *keyValuePair = nil;
    if ([value isKindOfClass:[BMKeyValuePair class]]) {
        keyValuePair = (BMKeyValuePair *)value;
        value = keyValuePair.value;
    }
    
	NSObject *content;
	if (value != nil && self.converterSelector != nil) {
		id ct = self.converterTarget;
		if (!ct) ct = target;
		content = [ct performSelector:self.converterSelector withObject:value];
		if (content == nil) {
			LogWarn(@"Warning: converter returned nil for target [%@ %@[%@@\"%@\"]]", [ct class], NSStringFromSelector(self.setterSelector), NSStringFromSelector(self.converterSelector), value); 
		}
	} else {
		content = value;
	}

    if (self.isArray) {
        if (content != nil) {
            id theArray = [target performSelector:self.getterSelector];
            if (!theArray) {
                //First set the array:
                theArray = [NSMutableArray array];
                [target performSelector:self.setterSelector withObject:theArray];
            }
            [theArray performSelector:@selector(addObject:) withObject:content];
        }
    } else if (self.isSet) {
        if (content != nil) {
            id theSet = [target performSelector:self.getterSelector];
            if (!theSet) {
                //First set the array:
                theSet = [NSMutableOrderedSet new];
                [target performSelector:self.setterSelector withObject:theSet];
            }
            [theSet performSelector:@selector(addObject:) withObject:content];
        }
    } else if (self.isDictionary) {
        id theDictionary = [target performSelector:self.getterSelector];
        if (!theDictionary) {
			//First set the array:
			theDictionary = [NSMutableDictionary dictionary];
			[target performSelector:self.setterSelector withObject:theDictionary];
		}
        
        if (keyValuePair) {
            if (keyValuePair.key) {
                if (content == nil) {
                    [theDictionary performSelector:@selector(removeObjectForKey:) withObject:keyValuePair.key];
                } else {
                    [theDictionary performSelector:@selector(setObject:forKey:) withObject:content withObject:keyValuePair.key];
                }
            } else {
                LogWarn(@"Warning: key is nil for dictionary mapping. Setter=%@, value=%@", NSStringFromSelector(self.setterSelector), value);
            }
        }
		
	} else {
		[target performSelector:self.setterSelector withObject:content];
	}
}

- (id)inverseConvertValue:(id)oriValue withTarget:(id)target{
    id value = oriValue;
    if (self.inverseConverterSelector != nil) {
        @try {
            if (self.inverseConverterTarget) {
                value = [self.inverseConverterTarget performSelector:self.inverseConverterSelector withObject:value];
            } else {
                value = [value performSelector:self.inverseConverterSelector];
            }
        }
        @catch (NSException *exception) {
            LogWarn(@"Could not convert value '%@' with inverse converter for target: %@: %@", oriValue, target, exception);
            value = nil;
        }
		if (value == nil && oriValue != nil) {
			LogWarn(@"Warning: inverse converter returned nil for target: %@", target);
		}
	}
    return value;
}

- (NSObject *)invokeGetterOnTarget:(NSObject <BMMappableObject> *)target {
    NSObject *value = [self invokeRawGetterOnTarget:target];
    
    if (self.inverseConverterSelector != nil) {
        if (self.isDictionary && [value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)value;
            BMOrderedDictionary *retDict = [BMOrderedDictionary dictionary];
            for (id key in dict) {
                id dictValue = [dict objectForKey:key];
                dictValue = [self inverseConvertValue:dictValue withTarget:target];
                if (dictValue) {
                    [retDict setObject:dictValue forKey:key];
                }
            }
            value = retDict;
        } else if (self.isArray && [value conformsToProtocol:@protocol(NSFastEnumeration)]) {
            NSMutableArray *retArray = [NSMutableArray array];
            for (id v in (id<NSFastEnumeration>)value) {
                id convertedValue = [self inverseConvertValue:v withTarget:target];
                if (convertedValue) {
                    [retArray addObject:convertedValue];
                }
            }
            value = retArray;
        } else if (self.isSet && [value conformsToProtocol:@protocol(NSFastEnumeration)]) {
            NSMutableOrderedSet *retSet = [NSMutableOrderedSet new];
            for (id v in (id<NSFastEnumeration>)value) {
                id convertedValue = [self inverseConvertValue:v withTarget:target];
                if (convertedValue) {
                    [retSet addObject:convertedValue];
                }
            }
            value = retSet;
        } else {
            value = [self inverseConvertValue:value withTarget:target];
        }
    }
	return value;
}

- (NSObject *)invokeRawGetterOnTarget:(NSObject <BMMappableObject> *)target {
    return [target performSelector:self.getterSelector];
}

- (void)invokeRawSetterOnTarget:(NSObject <BMMappableObject> *)target withValue:(NSObject *)value {
    [target performSelector:self.setterSelector withObject:value];
}

- (NSString *)fieldClassName {
	if (self.isArray) {
        return @"NSMutableArray";
    } else if (self.isSet) {
        return @"NSMutableOrderedSet";
	} else {
		return self.fieldObjectClassName;
	}
}

- (NSString *)fieldObjectClassName {
	if (fieldObjectClass) {
		return NSStringFromClass(fieldObjectClass);
	} else {
		return fieldObjectClassName;
	}
}

- (BOOL)isJSONStringField {
    NSArray *stringClassNames = @[@"NSString", @"NSURL", @"NSDate"];
    NSString *className = self.fieldObjectClassName;
    return className == nil || [stringClassNames containsObject:className];
}

- (BOOL)fieldObjectClassIsMappable {
	return [(id)fieldObjectClass conformsToProtocol:@protocol(BMMappableObject)];
}

- (BOOL)fieldObjectClassIsCustom {
	return self.fieldObjectClassIsMappable || (fieldObjectClass == nil && fieldObjectClassName != nil);
}

- (NSString *)fieldMappingFormatString {
	if (fieldFormat) {
		return [NSString stringWithFormat:@"%@;%@;%@", fieldName, mappingPath, fieldFormat];
	} else if ([mappingPath isEqual:fieldName]) {
		return fieldName;
	} else {
		return [NSString stringWithFormat:@"%@;%@", fieldName, mappingPath];
	}
}
			
- (NSString *)fieldFormat {
	return fieldFormat;
}

- (BOOL)isCollection {
    return self.isSet || self.isArray;
}

- (NSValueTransformer *)valueTransformer {
	return [[BMValueTransformer alloc] initWithConverterTarget:self.converterTarget 
											  converterSelector:self.converterSelector
												  inverseTarget:self.inverseConverterTarget 
												inverseSelector:self.inverseConverterSelector];
}

- (void)setMappingPath:(NSString *)path {
    
    BM_RELEASE_SAFELY(attributeName);
    BM_RELEASE_SAFELY(elementNameComponents);
    BM_AUTORELEASE_SAFELY(mappingPath);
    
    if (path) {
        NSMutableArray *components = [NSMutableArray arrayWithArray:[path componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:MAPPING_ELEMENT_SEPARATOR]]];
        NSString *lastComponent = [components lastObject];
        NSArray *lastComponents = [lastComponent componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:MAPPING_ATTRIBUTE_SEPARATOR]];
        
        if (lastComponents.count > 1) {
            lastComponent = [lastComponents objectAtIndex:0];
            attributeName = [lastComponents objectAtIndex:1];
            [components removeLastObject];
            [components addObject:lastComponent];
        }
        
        elementNameComponents = [NSArray arrayWithArray:components];
        mappingPath = path;
    }
}

- (NSUInteger)hash {
    return self.fieldMappingFormatString.hash;
}

- (BOOL)isEqual:(id)object {
    BOOL equal = NO;
    
    if ([object isKindOfClass:[self class]]) {
        equal = [self.fieldMappingFormatString isEqualToString:[object fieldMappingFormatString]];
    }
    return equal;
}

@end

@implementation BMFieldMapping(Private)

- (void)setConverterTarget:(id)target {
	if (target != converterTarget) {
		converterTarget = nil;
		converterTarget = target;
	}
}

- (void)setInverseConverterTarget:(id)target {
    if (target != inverseConverterTarget) {
		inverseConverterTarget = nil;
		inverseConverterTarget = target;
	}
}

- (void)initSelectorFromFieldName:(NSString *)theFieldName andType:(NSString *)type andFormat:(NSString *)format {
	getterSelector = NSSelectorFromString(theFieldName);
	if ([type isEqualToString:@"custom"]) {
		setterSelector = NSSelectorFromString([format stringByAppendingString:@":"]);
	} else {
		array = [type isEqualToString:@"array"];
        dictionary = [type isEqualToString:@"dictionary"];
        set = [type isEqualToString:@"set"];
		
		NSString *setterName = @"";
		if (theFieldName.length > 0) {
			NSString *firstChar = [[theFieldName substringToIndex:1] uppercaseString];
			setterName = [NSString stringWithFormat:@"set%@%@:", firstChar, [theFieldName substringFromIndex:1]];
		}		
		setterSelector = NSSelectorFromString(setterName);
	}
}

- (void)initConverterWithType:(NSString *)type subType:(NSString *)subType andFormat:(NSString *)format {
    if ([subType isEqualToString:@"string"]) {
        //Do nothing
    } else if ([subType isEqualToString:@"int"]) {
		converterSelector = @selector(intNumberForString:);
		self.converterTarget = [BMNumberHelper class];
		inverseConverterSelector = @selector(stringValue);
		fieldObjectClass = [NSNumber class];
	} else if ([subType isEqualToString:@"double"]) {
		converterSelector = @selector(doubleNumberForString:);
		self.converterTarget = [BMNumberHelper class];
		inverseConverterSelector = @selector(stringValue);
		fieldObjectClass = [NSNumber class];
	} else if ([subType isEqualToString:@"bool"]) {
		converterSelector = @selector(boolNumberForString:);
		self.converterTarget = [BMNumberHelper class];	
		inverseConverterSelector = @selector(bmBoolStringValue);
		fieldObjectClass = [NSNumber class];
	} else if ([subType isEqualToString:@"url"]) {
		converterSelector = @selector(urlFromString:);
		self.converterTarget = [BMStringHelper class];
        inverseConverterSelector = @selector(absoluteString);
        self.inverseConverterTarget = nil;
		fieldObjectClass = [NSURL class];
	} else if ([subType isEqualToString:@"date"]) {
		converterSelector = @selector(bmDateByParsingFromString:);
		inverseConverterSelector = @selector(stringFromDate:);
        if ([BMStringHelper isEmpty:format]) {
            //Default
            format = [[self class] defaultDateFormat];
        }
		if (![BMStringHelper isEmpty:format]) {
			if ([format isEqualToString:@"standardTime"]) {
				self.converterTarget = [BMDateHelper standardTimestampFormatter];
			} else if ([format isEqualToString:@"RFC3339"]) {
				self.converterTarget = [BMDateHelper class];
				converterSelector = @selector(dateFromRFC3339String:);
				inverseConverterSelector = @selector(rfc3339StringFromDate:);
			} else if ([format isEqualToString:@"standardDate"]) {
				self.converterTarget = [BMDateHelper standardDateFormatter];
			} else {
				self.converterTarget = [BMDateHelper dateformatterWithFormat:format andTimeZone:[[self class] defaultTimeZone]];
			}
		} else {
            self.converterTarget = [BMDateHelper defaultDateFormatter];
        }
        if (!converterTarget) {
            NSException *ex = [NSException exceptionWithName:@"InvalidFieldMappingException" reason:[NSString stringWithFormat:@"Invalid date format specified: %@", format] userInfo:nil];
            @throw ex;
        }
        
		self.inverseConverterTarget = converterTarget;
		fieldObjectClass = [NSDate class];
        date = YES;
	} else if (subType && ([type isEqualToString:@"object"] || [type isEqualToString:@"custom"] || [type isEqualToString:@"array"] || [type isEqualToString:@"dictionary"])) {
		if ([subType isEqual:type]) {
			//Default sub type is string
			fieldObjectClass = [NSString class];
		} else {
            BM_RELEASE_SAFELY(fieldObjectClassName);
            fieldObjectClassName = subType;
            fieldObjectClass = NSClassFromString(subType);
            if (classChecksEnabled && !self.fieldObjectClassIsMappable) {
                NSException *ex = [NSException exceptionWithName:@"InvalidFieldMappingException" 
                                                          reason:[NSString stringWithFormat:@"Invalid class specified: '%@'. Could not be found or is no mappable class. Failed fieldName: %@, mappingPath: %@",
                                                                  subType, self.fieldName, self.mappingPath]
                                                        userInfo:nil];
                @throw ex;
            }
		}
        
	} else {
		NSException *ex = [NSException exceptionWithName:@"InvalidFieldMappingException" 
												  reason:[NSString stringWithFormat:@"Unrecognized subtype specified: '%@' for type %@ in fieldName: %@, mappingPath: %@",
														  subType, type, self.fieldName, self.mappingPath]
												userInfo:nil];
		@throw ex;
	}
}

@end

