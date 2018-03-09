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
#import <BMCommons/NSObject+BMCommons.h>
#import <BMCommons/NSString+BMCommons.h>
#import <BMCommons/BMObjectMapping.h>

@interface BMFieldMapping(Private)

- (void)initSelectorFromFieldName:(NSString *)fieldName andType:(NSString *)type andFormat:(NSString *)format;
- (BOOL)initConverterWithType:(NSString *)type subType:(NSString *)subType andFormat:(NSString *)format error:(NSError **)error;
- (void)setConverterTarget:(id)target;
- (void)setInverseConverterTarget:(id)target;

@end

@implementation BMFieldMapping {
@private
    NSString *_fieldName;
    NSString *_fieldFormat;
    NSString *_namespaceURI;
    
    NSArray *_elementNameComponents;
    NSString *_attributeName;
    NSString *_mappingPath;
    
    SEL _setterSelector;
    SEL _getterSelector;
    SEL _converterSelector;
    id _converterTarget;
    SEL _inverseConverterSelector;
    id _inverseConverterTarget;
    BOOL _array;
    BOOL _set;
    BOOL _dictionary;
    BOOL _date;
    Class _fieldObjectClass;
    NSString *_fieldObjectClassName;
    NSString *_swiftClassName;
}

static BOOL classChecksEnabled = YES;
static NSString *defaultDateFormat = nil;
static NSTimeZone *defaultTimeZone = nil;

@synthesize namespaceURI = _namespaceURI;
@synthesize fieldName = _fieldName;
@synthesize setterSelector = _setterSelector;
@synthesize converterSelector = _converterSelector;
@synthesize converterTarget = _converterTarget;
@synthesize inverseConverterTarget = _inverseConverterTarget;
@synthesize inverseConverterSelector = _inverseConverterSelector;
@synthesize getterSelector = _getterSelector;
@synthesize array = _array;
@synthesize elementNameComponents = _elementNameComponents;
@synthesize attributeName = _attributeName;
@synthesize mappingPath = _mappingPath;
@synthesize fieldObjectClass = _fieldObjectClass;
@synthesize date = _date;
@synthesize dictionary = _dictionary;
@synthesize set = _set;

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
	return [self parseFieldDescriptorDictionary:dict withNamespaces:nil error:nil];
}

+ (void)initialize {
    if (!defaultDateFormat) {
        [self setDefaultDateFormat:@"RFC3339"];
    }
    if (!defaultTimeZone) {
        [self setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
}

+ (NSDictionary *)parseFieldDescriptorDictionary:(NSDictionary *)dict withNamespaces:(NSDictionary *)namespaceDict error:(NSError **)error {
	NSMutableDictionary *ret = [[BMOrderedDictionary alloc] initWithCapacity:dict.count];
	for (NSString *key in dict) {
		NSString *fieldDescriptor = [dict objectForKey:key];
		BMFieldMapping *fieldMapping = [[BMFieldMapping alloc] initWithFieldDescriptor:fieldDescriptor mappingPath:key];
		if (fieldMapping != nil) {
			fieldMapping.namespaceURI = [namespaceDict objectForKey:key];
			[ret setObject:fieldMapping forKey:key];
		} else {
            if (error) {
                *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_DATA code:BM_ERROR_INVALID_DATA description:[NSString stringWithFormat:@"Could not parse field descriptor '%@' for key '%@'", fieldDescriptor, key]];
            }
            return nil;
		}
	}
	return ret;
}

- (id)init {
    if ((self = [super init])) {
        self.minLength = 0;
        self.maxLength = -1;
        self.minItems = 0;
        self.maxItems = -1;
        self.uniqueItems = NO;
    }
    return self;
}

- (id)initWithFieldDescriptor:(NSString *)fieldDescriptor mappingPath:(NSString *)theMappingPath {
	if ((self = [self init])) {
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
            if (_fieldFormat) {
                _fieldFormat = [_fieldFormat stringByAppendingFormat:@":%@", currentComponent];
            } else {
                _fieldFormat = currentComponent;
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
    
    _fieldName = [fieldComponents objectAtIndex:0];
    
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

    [self initSelectorFromFieldName:_fieldName andType:type andFormat:format];
    if (!self.setterSelector || !self.getterSelector) {
        if (error) {
            *error = [BMErrorHelper genericErrorWithDescription:@"Could not determine getter and/or setter selector"];
        }
        return NO;
    }
    
    //Default class is NSString
    _fieldObjectClass = [NSString class];
    _swiftClassName = nil;
    _fieldObjectClassName = nil;
    if (type && subType) {
        if (![self initConverterWithType:type subType:subType andFormat:format error:error]) {
            return NO;
        }
    }
    if ([self.fieldObjectClassName isEqual:@"NSString"]) {
        _swiftClassName = @"String";
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
        BM_IGNORE_SELECTOR_LEAK_WARNING(
		content = [ct performSelector:self.converterSelector withObject:value];
        )
		if (content == nil) {
			LogWarn(@"Warning: converter returned nil for target [%@ %@[%@@\"%@\"]]", [ct class], NSStringFromSelector(self.setterSelector), NSStringFromSelector(self.converterSelector), value); 
		}
	} else {
		content = value;
	}

    if (self.isArray) {
        if (content != nil) {
            BM_IGNORE_SELECTOR_LEAK_WARNING(
            id theArray = [target performSelector:self.getterSelector];
            )
            if (!theArray) {
                //First set the array:
                theArray = [NSMutableArray new];
                BM_IGNORE_SELECTOR_LEAK_WARNING(
                [target performSelector:self.setterSelector withObject:theArray];
                )
            }
            BM_IGNORE_SELECTOR_LEAK_WARNING(
            [theArray performSelector:@selector(addObject:) withObject:content];
            )
        }
    } else if (self.isSet) {
        if (content != nil) {
            BM_IGNORE_SELECTOR_LEAK_WARNING(
            id theSet = [target performSelector:self.getterSelector];
            )
            if (!theSet) {
                //First set the array:
                theSet = [NSMutableOrderedSet new];
                BM_IGNORE_SELECTOR_LEAK_WARNING(
                [target performSelector:self.setterSelector withObject:theSet];
                )
            }
            BM_IGNORE_SELECTOR_LEAK_WARNING(
            [theSet performSelector:@selector(addObject:) withObject:content];
            )
        }
    } else if (self.isDictionary) {
        BM_IGNORE_SELECTOR_LEAK_WARNING(
        id theDictionary = [target performSelector:self.getterSelector];
        )
        if (!theDictionary) {
			//First set the array:
			theDictionary = [BMOrderedDictionary new];
            BM_IGNORE_SELECTOR_LEAK_WARNING(
			[target performSelector:self.setterSelector withObject:theDictionary];
            )
		}
        
        if (keyValuePair) {
            if (keyValuePair.key) {
                if (content == nil) {
                    BM_IGNORE_SELECTOR_LEAK_WARNING(
                    [theDictionary performSelector:@selector(removeObjectForKey:) withObject:keyValuePair.key];
                    )
                } else {
                    BM_IGNORE_SELECTOR_LEAK_WARNING(
                    [theDictionary performSelector:@selector(setObject:forKey:) withObject:content withObject:keyValuePair.key];
                    )
                }
            } else {
                LogWarn(@"Warning: key is nil for dictionary mapping. Setter=%@, value=%@", NSStringFromSelector(self.setterSelector), value);
            }
        }
		
	} else {
        BM_IGNORE_SELECTOR_LEAK_WARNING(
		[target performSelector:self.setterSelector withObject:content];
        )
	}
}

- (id)inverseConvertValue:(id)oriValue withTarget:(id)target{
    id value = oriValue;
    if (self.inverseConverterSelector != nil) {
        @try {
            if (self.inverseConverterTarget) {
                BM_IGNORE_SELECTOR_LEAK_WARNING(
                value = [self.inverseConverterTarget performSelector:self.inverseConverterSelector withObject:value];
                )
            } else {
                BM_IGNORE_SELECTOR_LEAK_WARNING(
                value = [value performSelector:self.inverseConverterSelector];
                )
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
    BM_IGNORE_SELECTOR_LEAK_WARNING(
    return [target performSelector:self.getterSelector];
    )
}

- (void)invokeRawSetterOnTarget:(NSObject <BMMappableObject> *)target withValue:(NSObject *)value {
    BM_IGNORE_SELECTOR_LEAK_WARNING(
    [target performSelector:self.setterSelector withObject:value];
    )
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
    NSString *ret = nil;
	if (_fieldObjectClass) {
		ret = NSStringFromClass(_fieldObjectClass);
	} else {
		ret = _fieldObjectClassName;
	}
    return ret;
}

- (NSString *)swiftFieldClassName {
    NSString *fieldObjectClassName = self.swiftFieldObjectClassName;
    if (self.isArray) {
        return @"Array";
    } else if (self.isSet) {
        return @"Set";
    } else {
        return fieldObjectClassName;
    }
}

- (NSString *)swiftFieldObjectClassName {
    if (_swiftClassName) {
        return _swiftClassName;
    } else {
        return self.unqualifiedFieldObjectClassName;
    }
}

- (BOOL)isJSONStringField {
    NSArray *stringClassNames = @[@"NSString", @"NSURL", @"NSDate"];
    NSString *className = self.fieldObjectClassName;
    return className == nil || [stringClassNames containsObject:className];
}

- (BOOL)fieldObjectClassIsMappable {
	return [(id)_fieldObjectClass conformsToProtocol:@protocol(BMMappableObject)];
}

- (BOOL)fieldObjectClassIsCustom {
	return self.fieldObjectClassIsMappable || (_fieldObjectClass == nil && _fieldObjectClassName != nil);
}

- (NSString *)fieldMappingFormatString {
	if (_fieldFormat) {
		return [NSString stringWithFormat:@"%@;%@;%@", _fieldName, _mappingPath, _fieldFormat];
	} else if ([_mappingPath isEqual:_fieldName]) {
		return _fieldName;
	} else {
		return [NSString stringWithFormat:@"%@;%@", _fieldName, _mappingPath];
	}
}

- (NSString *)unqualifiedFieldObjectClassName {
    return [self.fieldObjectClassName bmStringByCroppingUptoLastOccurenceOfString:@"."];
}
			
- (NSString *)fieldFormat {
	return _fieldFormat;
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

- (BOOL)isEnumeration {
    return self.enumeratedValues.count > 0;
}

- (BOOL)isStringEnumeration {
    return self.isEnumeration && [self.fieldClassName isEqual:@"NSString"];
}

- (NSString *)enumerationTypeName {
    NSString *ret = nil;
    if (self.isEnumeration) {
        ret = [NSString stringWithFormat:@"%@%@Type", self.parentObjectMapping.unqualifiedObjectClassName, [self.fieldName bmStringWithUppercaseFirstChar]];
    }
    return ret;
}

- (BOOL)hasConstraints {
    return self.schemaFieldFormatType >= 3 || self.pattern != nil || self.minLength > 0 || self.maxLength >= 0 || self.uniqueItems || self.minItems > 0 || self.maxItems >= 0;
}

- (NSString *)escapedPattern {
    NSString *ret = self.pattern;
    ret = [ret stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    ret = [ret stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    return ret;
}

- (void)setMappingPath:(NSString *)path {
    
    BM_RELEASE_SAFELY(_attributeName);
    BM_RELEASE_SAFELY(_elementNameComponents);
    BM_AUTORELEASE_SAFELY(_mappingPath);
    
    if (path) {
        NSMutableArray *components = [NSMutableArray arrayWithArray:[path componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:MAPPING_ELEMENT_SEPARATOR]]];
        NSString *lastComponent = [components lastObject];
        NSArray *lastComponents = [lastComponent componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:MAPPING_ATTRIBUTE_SEPARATOR]];
        
        if (lastComponents.count > 1) {
            lastComponent = [lastComponents objectAtIndex:0];
            _attributeName = [lastComponents objectAtIndex:1];
            [components removeLastObject];
            [components addObject:lastComponent];
        }
        
        _elementNameComponents = [NSArray arrayWithArray:components];
        _mappingPath = path;
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
	if (target != _converterTarget) {
		_converterTarget = nil;
		_converterTarget = target;
	}
}

- (void)setInverseConverterTarget:(id)target {
    if (target != _inverseConverterTarget) {
		_inverseConverterTarget = nil;
		_inverseConverterTarget = target;
	}
}

- (void)initSelectorFromFieldName:(NSString *)theFieldName andType:(NSString *)type andFormat:(NSString *)format {
	_getterSelector = NSSelectorFromString(theFieldName);
	if ([type isEqualToString:@"custom"]) {
		_setterSelector = NSSelectorFromString([format stringByAppendingString:@":"]);
	} else {
		_array = [type isEqualToString:@"array"];
        _dictionary = [type isEqualToString:@"dictionary"];
        _set = [type isEqualToString:@"set"];
		
		NSString *setterName = @"";
		if (theFieldName.length > 0) {
			NSString *firstChar = [[theFieldName substringToIndex:1] uppercaseString];
			setterName = [NSString stringWithFormat:@"set%@%@:", firstChar, [theFieldName substringFromIndex:1]];
		}		
		_setterSelector = NSSelectorFromString(setterName);
	}
}

- (BOOL)initConverterWithType:(NSString *)type subType:(NSString *)subType andFormat:(NSString *)format error:(NSError **)error {
    if ([subType isEqualToString:@"string"]) {
        //Do nothing
    } else if ([subType isEqualToString:@"int"]) {
		_converterSelector = @selector(intNumberForString:);
		self.converterTarget = [BMNumberHelper class];
		_inverseConverterSelector = @selector(stringValue);
		_fieldObjectClass = [NSNumber class];
        _swiftClassName = @"Int";
	} else if ([subType isEqualToString:@"double"]) {
		_converterSelector = @selector(doubleNumberForString:);
		self.converterTarget = [BMNumberHelper class];
		_inverseConverterSelector = @selector(stringValue);
		_fieldObjectClass = [NSNumber class];
        _swiftClassName = @"Double";
	} else if ([subType isEqualToString:@"bool"]) {
		_converterSelector = @selector(boolNumberForString:);
		self.converterTarget = [BMNumberHelper class];	
		_inverseConverterSelector = @selector(bmBoolStringValue);
		_fieldObjectClass = [NSNumber class];
        _swiftClassName = @"Bool";
	} else if ([subType isEqualToString:@"url"]) {
		_converterSelector = @selector(urlFromString:);
		self.converterTarget = [BMStringHelper class];
        _inverseConverterSelector = @selector(absoluteString);
        self.inverseConverterTarget = nil;
		_fieldObjectClass = [NSURL class];
        _swiftClassName = @"URL";
	} else if ([subType isEqualToString:@"date"]) {
		_converterSelector = @selector(bmDateByParsingFromString:);
		_inverseConverterSelector = @selector(stringFromDate:);
        if ([BMStringHelper isEmpty:format]) {
            //Default
            format = [[self class] defaultDateFormat];
        }
		if (![BMStringHelper isEmpty:format]) {
			if ([format isEqualToString:@"standardTime"]) {
				self.converterTarget = [BMDateHelper standardTimestampFormatter];
			} else if ([format isEqualToString:@"RFC3339"]) {
				self.converterTarget = [BMDateHelper class];
				_converterSelector = @selector(dateFromRFC3339String:);
				_inverseConverterSelector = @selector(rfc3339StringFromDate:);
			} else if ([format isEqualToString:@"standardDate"]) {
				self.converterTarget = [BMDateHelper standardDateFormatter];
			} else {
				self.converterTarget = [BMDateHelper dateformatterWithFormat:format andTimeZone:[[self class] defaultTimeZone]];
			}
		} else {
            self.converterTarget = [BMDateHelper defaultDateFormatter];
        }
        if (!_converterTarget) {
            if (error) {
                *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_DATA code:BM_ERROR_INVALID_DATA description:[NSString stringWithFormat:@"Invalid date format specified: %@", format]];
            }
            return NO;
        }
        
		self.inverseConverterTarget = _converterTarget;
		_fieldObjectClass = [NSDate class];
        _swiftClassName = @"Date";
        _date = YES;
	} else if (subType && ([type isEqualToString:@"object"] || [type isEqualToString:@"custom"] || [type isEqualToString:@"array"] || [type isEqualToString:@"set"] || [type isEqualToString:@"dictionary"])) {
		if ([subType isEqual:type]) {
			//Default sub type is string
			_fieldObjectClass = [NSString class];
            _swiftClassName = @"String";
		} else {
            _fieldObjectClassName = subType;
            _fieldObjectClass = NSClassFromString(subType);
            if (classChecksEnabled && !self.fieldObjectClassIsMappable) {
                if (error) {
                    *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_DATA code:BM_ERROR_INVALID_DATA description:[NSString stringWithFormat:@"Invalid class specified: '%@'. Could not be found or is no mappable class. Failed fieldName: %@, mappingPath: %@",
                                                                                                                                                  subType, self.fieldName, self.mappingPath]];
                }
                return NO;
            }
		}
        
	} else {
        if (error) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_DATA code:BM_ERROR_INVALID_DATA description:[NSString stringWithFormat:@"Unrecognized subtype specified: '%@' for type %@ in fieldName: %@, mappingPath: %@",
                                                                                                                                          subType, type, self.fieldName, self.mappingPath]];
        }
        return NO;
	}
    return YES;
}

@end

