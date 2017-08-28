//
//  BMAbstractMappableObject.m
//  BMCommons
//
//  Created by Werner Altewischer on 20/05/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAbstractMappableObject.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMPropertyDescriptor.h>
#import <BMCommons/BMOrderedDictionary.h>
#import <BMCommons/BMObjectMappingParserHandler.h>
#import <BMCommons/BMXMLParser.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/BMJSONParser.h>
#import <BMCommons/BMObjectHelper.h>
#import <BMCommons/BMXMLElement.h>
#import <BMCommons/BMMappableObjectXMLSerializer.h>
#import <BMCommons/BMMappableObjectJSONSerializer.h>
#import <BMCommons/BMRestKit.h>
#import <BMCommons/NSObject+BMCommons.h>

@interface BMAbstractMappableObject(Private)

+ (BOOL)appendDataForValue:(id)value forKeyPath:(NSString *)keyPath toDigest:(BMDigest *)digest ignoredKeyPaths:(NSSet<NSString *> *)ignoredKeyPaths;

- (NSString *)namespacePrefixForURI:(NSString *)childNamespaceURI withNamespaces:(NSMutableDictionary *)namespaces;
- (id)deepCopyValue:(id)otherValue;
- (id)shallowCopyValue:(id)otherValue;

@end

@implementation BMAbstractMappableObject

static NSString * const kVersionKey = @"__serialVersionUID";

static NSMutableDictionary *fieldMappingsCache = nil;
static NSMutableDictionary *propertyDescriptorCache = nil;
static NSMutableDictionary *propertyCache = nil;
static NSCharacterSet *invalidPropertyCharacterSet = nil;
static NSCharacterSet *invalidElementCharacterSet = nil;
static NSCharacterSet *invalidFormatCharacterSet = nil;
static NSMutableDictionary *serialVersionUIDCache = nil;

+ (void)initialize {
	if (self == BMAbstractMappableObject.class) {
		if (!fieldMappingsCache) {
			fieldMappingsCache = [BMOrderedDictionary new];
		}

		if (!propertyCache) {
			propertyCache = [BMOrderedDictionary new];
		}

		if (!serialVersionUIDCache) {
			serialVersionUIDCache = [NSMutableDictionary new];
		}

		if (!propertyDescriptorCache) {
			propertyDescriptorCache = [BMOrderedDictionary new];
		}
		if (!invalidPropertyCharacterSet) {
			invalidPropertyCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@":,/\\?'\"{}()-+|!*&%"];
		}
		if (!invalidElementCharacterSet) {
			invalidElementCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@",\\?'\"{}()+|!*&%"];
		}
		if (!invalidFormatCharacterSet) {
			invalidFormatCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@""];
		}
	}
}

+ (NSDictionary *)fieldMappingDictionary {
	NSArray *formats = [self fieldMappingFormatArray];
	NSMutableDictionary *ret = [BMOrderedDictionary dictionaryWithCapacity:formats.count];
	for (NSString *format in formats) {
		NSArray *components = [format componentsSeparatedByString:@";"];
		
		NSString *propertyName = [components objectAtIndex:0];
		
		if (propertyName && [propertyName rangeOfCharacterFromSet:invalidPropertyCharacterSet].location != NSNotFound) {
			NSException *exception = [NSException exceptionWithName:@"InvalidMappingException" 
															 reason:[NSString stringWithFormat:@"Invalid character in propertyName part of mapping: %@ for class: %@", format, self] 
														   userInfo:nil];
			@throw exception;
		}
		
		NSString *propertyFormat = components.count > 2 ? [components objectAtIndex:2] : nil;
		
		if (propertyFormat && [propertyFormat rangeOfCharacterFromSet:invalidFormatCharacterSet].location != NSNotFound) {
			NSException *exception = [NSException exceptionWithName:@"InvalidMappingException" 
															 reason:[NSString stringWithFormat:@"Invalid character in format part of mapping: %@ for class: %@", format, self] 
														   userInfo:nil];
			@throw exception;
		}
		
		
		NSString *fullPropertyFormat = propertyFormat ? [NSString stringWithFormat:@"%@:%@", propertyName, propertyFormat] : propertyName;
		NSString *elementName = components.count > 1 ? [components objectAtIndex:1] : propertyName;
		
		if (elementName && [elementName rangeOfCharacterFromSet:invalidElementCharacterSet].location != NSNotFound) {
			NSException *exception = [NSException exceptionWithName:@"InvalidMappingException" 
															 reason:[NSString stringWithFormat:@"Invalid character in element part of mapping: %@ for class: %@", format, self] 
														   userInfo:nil];
			@throw exception;
		}
		
		[ret setObject:fullPropertyFormat forKey:elementName];
	}
	return ret;
}

+ (NSDictionary *)fieldMappings {
	id key = NSStringFromClass([self class]);
	@synchronized ([BMAbstractMappableObject class]) {
		NSDictionary *dict = [fieldMappingsCache objectForKey:key];
		if (!dict) {
			NSDictionary *mappingNamespaces = [self fieldMappingNamespaces];
			NSError *error = nil;
			dict = [BMFieldMapping parseFieldDescriptorDictionary:[self fieldMappingDictionary] withNamespaces:mappingNamespaces error:&error];

			if (dict) {
				[fieldMappingsCache setObject:dict forKey:key];
			} else {
				NSException *exception = [NSException exceptionWithName:@"BMInvalidFieldMappingException" reason:error.localizedDescription userInfo:nil];
				@throw exception;
			}
		}
		return dict;
	}
}

+ (BMPropertyDescriptor *)propertyDescriptorForPropertyName:(NSString *)propertyName {
	@synchronized ([BMAbstractMappableObject class]) {
		BMPropertyDescriptor *pd = [propertyDescriptorCache objectForKey:propertyName];
		if (!pd) {
			pd = [BMPropertyDescriptor propertyDescriptorFromKeyPath:propertyName withTarget:nil];
			[propertyDescriptorCache setObject:pd forKey:propertyName];
		}
		return pd;
	}
}

+ (NSArray *)objectPropertiesArray {
	id key = NSStringFromClass([self class]);
	@synchronized ([BMAbstractMappableObject class]) {
		NSMutableArray *ivarArray = [propertyCache objectForKey:key];

		if (!ivarArray) {
			ivarArray = [NSMutableArray array];
			for (NSString *ivarFormat in [self fieldMappingFormatArray]) {
				NSString *ivar = ivarFormat;
				NSRange range = [ivarFormat rangeOfString:@";"];
				if (range.location != NSNotFound) {
					ivar = [ivarFormat substringToIndex:range.location];
				}
				if (![ivarArray containsObject:ivar]) {
					[ivarArray addObject:ivar];
				}
			}

			[propertyCache setObject:ivarArray forKey:key];
		}
		return ivarArray;
	}
}

+ (NSArray *)fieldMappingFormatArray {
    return nil;
}

+ (NSString *)namespaceURI {
	//Default no namespace
	return nil;
}

+ (NSDictionary *)fieldMappingNamespaces {
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    BMAbstractMappableObject *copy = [[[self class] allocWithZone:zone] init];
    [copy mergeWithData:self ignoreNilValues:NO performClassCheck:YES deepMerge:YES];
    return copy;
}

- (id)shallowCopyWithZone:(NSZone *)zone {
	BMAbstractMappableObject *copy = [[[self class] allocWithZone:zone] init];
	[copy mergeWithData:self ignoreNilValues:NO performClassCheck:YES deepMerge:NO];
	return copy;
}

- (id)shallowCopy {
	return [self shallowCopyWithZone:nil];
}

- (void)encodeWithCoder:(NSCoder *)coder {
	for (NSString *ivar in [[self class] objectPropertiesArray]) {
		BMPropertyDescriptor *pd = [[self class] propertyDescriptorForPropertyName:ivar];
		if (pd) {
			id value = [pd callGetterOnTarget:self];
			[coder encodeObject:value forKey:ivar];
		}
	}
    [coder encodeInt64:self.class.serialVersionUID forKey:kVersionKey];
}

- (id)init {
    if ((self = [super init])) {

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [self init])) {
        int64_t version = [coder decodeInt64ForKey:kVersionKey];
        
        if (version != [[self class] serialVersionUID]) {
            LogWarn(@"Version of class %@ does not match with the version of the data to deserialize", [self class]);
            return nil;
        }
        for (NSString *ivar in [[self class] objectPropertiesArray]) {
			BMPropertyDescriptor *pd = [[self class] propertyDescriptorForPropertyName:ivar];
			if (pd) {
                [pd callSetterOnTarget:self withValue:[coder decodeObjectForKey:ivar]];
			}
		}
	}
	return self;
}

- (void)dealloc {
}

- (void)afterPropertiesSet {
	
}

static inline int64_t hash(NSString *s) {
	int64_t h = 0;
	if (s != nil && s.length > 0) {
		const char * buffer = [s cStringUsingEncoding:NSUTF8StringEncoding];
		int i = 0;
		while (YES) {
			char c = buffer[i++];
			if (c == '\0') {
				break;
			}
			h = 31 * h + (int64_t)c;
		}
	}
	return h;
}

+ (int64_t)serialVersionUID {
    @synchronized([BMAbstractMappableObject class]) {
        NSNumber *n = [serialVersionUIDCache objectForKey:self];
        if (n == nil) {
			int64_t version = hash(NSStringFromClass(self));
            for (BMFieldMapping *fieldMapping in [self.fieldMappings allValues]) {
                version += hash(fieldMapping.fieldMappingFormatString);
            }
            n = [NSNumber numberWithLongLong:version];
            [serialVersionUIDCache setObject:n forKey:(id <NSCopying>)self];
        }
        return [n longLongValue];
    }
}

- (NSString *)sha1Digest {
    BMDigest *digest = [BMDigest digestOfType:BMDigestTypeSHA1];
    [[self class] appendDataForValue:self forKeyPath:@"" toDigest:digest ignoredKeyPaths:self.class.keyPathsToIgnoreForDigest];
    [digest finalizeDigest];
    return [digest stringRepresentation];
}

+ (NSSet<NSString *> *)keyPathsToIgnoreForDigest {
	return nil;
}

/**
 The name of the root element or nil if this object is not mapped to a root XML element.
 */
+ (NSString *)rootElementName {
    return nil;
}

- (void)mergeWithData:(BMAbstractMappableObject *)other ignoreNilValues:(BOOL)ignoreNilValues {
    [self mergeWithData:other ignoreNilValues:ignoreNilValues performClassCheck:YES deepMerge:NO];
}

- (void)mergeWithData:(BMAbstractMappableObject *)other ignoreNilValues:(BOOL)ignoreNilValues performClassCheck:(BOOL)performClassCheck deepMerge:(BOOL)deepMerge {
    if (self != other) {
        
        if (performClassCheck) {
            if (![other isKindOfClass:[self class]]) {
                NSString *message = [NSString stringWithFormat:@"Argument is of the wrong class: %@, but should be: %@", NSStringFromClass([other class]), NSStringFromClass([self class])];
                NSException *ex = [NSException exceptionWithName:@"IllegalArgumentException" reason:message userInfo:nil];
                @throw ex;
            }
        }
        
        NSDictionary *thisClassFieldMappings = [[self class] fieldMappings];
        NSDictionary *otherClassFieldMappings = [[other class] fieldMappings];
        
        for (NSString *mappingName in thisClassFieldMappings) {
            
            BMFieldMapping *thisFieldMapping = [thisClassFieldMappings objectForKey:mappingName];
            BMFieldMapping *otherFieldMapping = [otherClassFieldMappings objectForKey:mappingName];
            
            if (thisFieldMapping.fieldObjectClass == otherFieldMapping.fieldObjectClass) {
                //Compatible mapping
                
                id otherValue = [otherFieldMapping invokeRawGetterOnTarget:other];
                
                if (deepMerge) {
                    otherValue = [self deepCopyValue:otherValue];
                } else {
					otherValue = [self shallowCopyValue:otherValue];
				}
                
                if (!ignoreNilValues || otherValue != nil) {
                    [thisFieldMapping invokeRawSetterOnTarget:self withValue:otherValue];
                }
            }
        }
    }
}

- (BOOL)validateWithError:(NSError **)error {
    NSArray *objectProperties = [[self class] objectPropertiesArray];    
    return [BMObjectHelper validateObject:self attributes:objectProperties withError:error];
}

@end

@implementation BMAbstractMappableObject(Private)

- (id)deepCopyValue:(id)otherValue {
    id otherValueCopy = otherValue;
    if ([otherValue isKindOfClass:[NSArray class]]) {
        
        otherValueCopy = [NSMutableArray new];
        
        for (id otherValueItem in otherValue) {
            id otherValueItemCopy = [self deepCopyValue:otherValueItem];
            [otherValueCopy addObject:otherValueItemCopy];
        }
    } else if ([otherValue isKindOfClass:[NSDictionary class]]) {
        
        otherValueCopy = [NSMutableDictionary new];
        
        for (NSObject *key in otherValue) {
            id value = [otherValue objectForKey:key];
            id <NSCopying> copiedKey = [key copy];
            
            id copiedValue = [self deepCopyValue:value];
            [otherValueCopy setObject:copiedValue forKey:copiedKey];
        }
        
    } else if ([otherValue conformsToProtocol:@protocol(NSCopying)]) {
        
        otherValueCopy = [otherValue copy];
        
    }
    return otherValueCopy;
}

- (id)shallowCopyValue:(id)otherValue {
	id otherValueCopy = otherValue;
	if ([otherValue isKindOfClass:[NSArray class]]) {

		otherValueCopy = [NSMutableArray new];

		for (id otherValueItem in otherValue) {
			id otherValueItemCopy = [self shallowCopyValue:otherValueItem];
			[otherValueCopy addObject:otherValueItemCopy];
		}
	} else if ([otherValue isKindOfClass:[NSDictionary class]]) {

		otherValueCopy = [NSMutableDictionary new];

		for (NSObject *key in otherValue) {
			id value = [otherValue objectForKey:key];
			id <NSCopying> copiedKey = [key copy];

			id copiedValue = [self shallowCopyValue:value];
			[otherValueCopy setObject:copiedValue forKey:copiedKey];
		}
	}
	return otherValueCopy;
}

- (NSString *)namespacePrefixForURI:(NSString *)namespaceURI withNamespaces:(NSMutableDictionary *)namespaces {
	NSString *namespacePrefix = nil;
	
	if (![BMStringHelper isEmpty:namespaceURI]) {
		namespacePrefix = [namespaces objectForKey:namespaceURI];
		
		if (!namespacePrefix) {
			//Generate a new prefix
			namespacePrefix = [NSString stringWithFormat:@"n%d", (int)(namespaces.count + 1)];
			[namespaces setObject:namespacePrefix forKey:namespaceURI];
		}
	}
	return namespacePrefix;
}

+ (BOOL)appendDataForValue:(id)value forKeyPath:(NSString *)keyPath toDigest:(BMDigest *)digest ignoredKeyPaths:(NSSet<NSString *> *)ignoredKeyPaths {
    BOOL ret = NO;
	if (ignoredKeyPaths == nil || ![ignoredKeyPaths containsObject:keyPath]) {
		if ([value isKindOfClass:[BMAbstractMappableObject class]]) {
			if ([self appendDataForValue:NSStringFromClass([value class]) forKeyPath:keyPath toDigest:digest ignoredKeyPaths:ignoredKeyPaths]) {
				for (BMFieldMapping *fm in [[[value class] fieldMappings] allValues]) {
					id valueItem = [fm invokeGetterOnTarget:value];
					NSString *fieldKeyPath = keyPath.length > 0 ? [keyPath stringByAppendingFormat:@".%@", fm.fieldName] : fm.fieldName;
					if ([self appendDataForValue:fm.fieldName forKeyPath:fieldKeyPath toDigest:digest ignoredKeyPaths:ignoredKeyPaths]) {
						[self appendDataForValue:valueItem forKeyPath:fieldKeyPath toDigest:digest ignoredKeyPaths:ignoredKeyPaths];
					}
				}
			}
		} else if ([value isKindOfClass:[NSArray class]]) {
			for (id valueItem in value) {
				[self appendDataForValue:valueItem forKeyPath:keyPath toDigest:digest ignoredKeyPaths:ignoredKeyPaths];
			}
		} else if ([value isKindOfClass:[NSDictionary class]]) {
			for (NSObject *key in value) {
				if ([self appendDataForValue:key forKeyPath:keyPath toDigest:digest ignoredKeyPaths:ignoredKeyPaths]) {
					id valueItem = [value objectForKey:key];
					[self appendDataForValue:valueItem forKeyPath:keyPath toDigest:digest ignoredKeyPaths:ignoredKeyPaths];
				}
			}
		} else {
			NSData *data = nil;
			NSString *s = nil;
			if (value == nil) {
				s = @"null";
			} else if ([value isKindOfClass:[NSString class]]) {
				s = value;
			} else if ([value isKindOfClass:[NSNumber class]]) {
				s = [value stringValue];
			} else if ([value isKindOfClass:[NSData class]]) {
				data = value;
			}

			if (data == nil) {
				if (s != nil) {
					data = [value dataUsingEncoding:NSUTF8StringEncoding];
				} else if ([value conformsToProtocol:@protocol(NSCoding)]) {
					data = [NSKeyedArchiver archivedDataWithRootObject:value];
				}
			}
			if (data != nil) {
				[digest updateWithData:data last:NO];
				ret = YES;
			}
		}
	}
    return ret;
}


@end

@implementation BMAbstractMappableObject(XMLSerialization)

/**
 The xmlElement with name equal to the root element or nil if rootElementName is not defined.
 */
- (BMXMLElement *)rootXmlElement {
    BMMappableObjectXMLSerializer *serializer = [BMMappableObjectXMLSerializer new];
    return [serializer rootXmlElementFromObject:self];
}

- (BMXMLElement *)xmlElementWithName:(NSString *)elementName namespaceURI:(NSString *)namespaceURI namespacePrefixes:(NSMutableDictionary *)namespacePrefixes {
	BMMappableObjectXMLSerializer *serializer = [BMMappableObjectXMLSerializer new];
    return [serializer xmlElementWithName:elementName namespaceURI:namespaceURI namespacePrefixes:namespacePrefixes fromObject:self jsonMode:NO];
}

- (BMXMLElement *)xmlElementWithName:(NSString *)elementName {
	BMMappableObjectXMLSerializer *serializer = [BMMappableObjectXMLSerializer new];
    return [serializer xmlElementWithName:elementName fromObject:self];
}

+ (instancetype)parsedObjectFromXMLData:(NSData *)data
                                   withRootXPath:(NSString *)xPath
                                           error:(NSError **)error {
	BMMappableObjectXMLSerializer *serializer = [BMMappableObjectXMLSerializer new];
    return [(NSObject *) [serializer parsedObjectFromXMLData:data withRootXPath:xPath forClass:[self class] error:error] bmCastSafely:self];
}

@end

@implementation BMAbstractMappableObject(JSONSerialization)


/**
 The json string with name equal to the root element or nil if the rootElementName is not defined.
 */
- (NSString *)rootJsonElement {
    BMMappableObjectJSONSerializer *serializer = [BMMappableObjectJSONSerializer new];
    return [serializer rootJsonElementFromObject:self];
}

+ (instancetype)parsedObjectFromJSONData:(NSData *)data
                                    withRootXPath:(NSString *)xPath
                                            error:(NSError **)error {
	BMMappableObjectJSONSerializer *serializer = [BMMappableObjectJSONSerializer new];
    return [(NSObject *) [serializer parsedObjectFromJSONData:data withRootXPath:xPath forClass:[self class] error:error] bmCastSafely:self];
}

+ (NSArray *)parsedArrayFromJSONData:(NSData *)data
                       withRootXPath:(NSString *)xPath
                               error:(NSError **)error {
	BMMappableObjectJSONSerializer *serializer = [BMMappableObjectJSONSerializer new];
    return [serializer parsedArrayFromJSONData:data withRootXPath:xPath forClass:[self class] error:error];
}

- (NSString *)jsonElementWithName:(NSString *)elementName {
    BMMappableObjectJSONSerializer *serializer = [BMMappableObjectJSONSerializer new];
    return [serializer jsonElementWithName:elementName fromObject:self];
}

- (NSString *)jsonElementWithName:(NSString *)elementName attributePrefix:(NSString *)attributePrefix
            textContentIdentifier:(NSString *)textContentIdentifier {
    BMMappableObjectJSONSerializer *serializer = [BMMappableObjectJSONSerializer new];
    return [serializer jsonElementWithName:elementName attributePrefix:attributePrefix textContentIdentifier:textContentIdentifier fromObject:self];
}

@end

@implementation BMAbstractMappableObject (CoreData)

+ (void)mergeDataObjects:(NSArray *)dataObjects
		withModelObjects:(NSArray *)modelObjects
			  modelClass:(Class)modelClass
  dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
 modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
		   mergeSelector:(SEL)mergeSelector
	   parentModelObject:(id)parentModelObject
			 addSelector:(SEL)addSelector
			   inContext:(NSManagedObjectContext *)context {

	BMPropertyDescriptor *pdData = [BMPropertyDescriptor propertyDescriptorFromKeyPath:dataPrimaryKeyProperty
																			withTarget:nil];

	BMPropertyDescriptor *pdModel = [BMPropertyDescriptor propertyDescriptorFromKeyPath:modelPrimaryKeyProperty
																			 withTarget:nil];

	NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithCapacity:dataObjects.count];

	for (id data in dataObjects) {
		id key = [pdData callGetterOnTarget:data];

		if (key == nil) {
			//Create a random key
			key = [BMStringHelper stringWithUUID];
		} else if ([dataDictionary objectForKey:key] != nil) {
			LogError(@"Found duplicate key!");
		}

		[dataDictionary setObject:data forKey:key];
	}

	NSMutableArray *objectsToRemove = [NSMutableArray array];

	for (id modelObject in modelObjects) {

		id key = [pdModel callGetterOnTarget:modelObject];
		id correspondingData = key ? [dataDictionary objectForKey:key] : nil;

		if (correspondingData) {
			//Existing object which should remain
			if (mergeSelector) {
				BM_IGNORE_SELECTOR_LEAK_WARNING(
						[correspondingData performSelector:mergeSelector withObject:modelObject];
				)
			}
			[dataDictionary removeObjectForKey:key];
		} else {
			//Object should be removed
			[objectsToRemove addObject:modelObject];
		}
	}

	//Objects to remove
	for (id modelObject in objectsToRemove) {
		[[modelObject managedObjectContext] deleteObject:modelObject];
	}

	//Objects to add
	for (id dataObject in [dataDictionary allValues]) {
		NSString *entityName = nil;

		Protocol *protocol = NSProtocolFromString(@"BMRootManagedObject");

		if (protocol && [modelClass conformsToProtocol:protocol] && [modelClass respondsToSelector:@selector(entityName)]) {
			BM_IGNORE_SELECTOR_LEAK_WARNING(
					entityName = [modelClass performSelector:@selector(entityName)];
			)
		}

		if (!entityName) {
			entityName = NSStringFromClass(modelClass);
		}

		id newObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];

		if (parentModelObject && addSelector) {
			BM_IGNORE_SELECTOR_LEAK_WARNING(
					[parentModelObject performSelector:addSelector withObject:newObject];
			)
		}
		if (mergeSelector) {
			BM_IGNORE_SELECTOR_LEAK_WARNING(
					[dataObject performSelector:mergeSelector withObject:newObject];
			)
		}
	}
}

+ (void)mergeDataObjects:(NSArray *)dataObjects
		withModelObjects:(NSArray *)modelObjects
				 ofClass:(Class)modelClass
  dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
 modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
		   mergeSelector:(SEL)mergeSelector
			   inContext:(NSManagedObjectContext *)context {

	[self mergeDataObjects:dataObjects
		  withModelObjects:modelObjects
				modelClass:modelClass
	dataPrimaryKeyProperty:dataPrimaryKeyProperty
   modelPrimaryKeyProperty:modelPrimaryKeyProperty
			 mergeSelector:mergeSelector
		 parentModelObject:nil
			   addSelector:nil
				 inContext:context];

}

+ (void)mergeDataObjects:(NSArray *)dataObjects
		 withModelObject:(NSManagedObject *)modelObject
 usingToManyRelationship:(NSString *)relationShip
  dataPrimaryKeyProperty:(NSString *)dataPrimaryKeyProperty
 modelPrimaryKeyProperty:(NSString *)modelPrimaryKeyProperty
		   mergeSelector:(SEL)mergeSelector {

	NSManagedObjectContext *context = [modelObject managedObjectContext];
	NSEntityDescription *entity = [modelObject entity];
	NSDictionary *relationShips = [entity relationshipsByName];
	NSRelationshipDescription *relationShipDescription = [relationShips objectForKey:relationShip];

	if (relationShipDescription && [relationShipDescription isToMany]) {

		NSSet *modelObjects = [modelObject valueForKey:relationShip];
		NSString *firstChar = relationShip.length > 0 ? [[relationShip substringToIndex:1] uppercaseString] : @"";
		NSString *rest = relationShip.length > 1 ? [relationShip substringFromIndex:1] : @"";
		NSString *capitalizedRelationshipName = [firstChar stringByAppendingString:rest];

		SEL addSelector = NSSelectorFromString([NSString stringWithFormat:@"add%@Object:", capitalizedRelationshipName]);
		Class modelClass = NSClassFromString([[relationShipDescription destinationEntity] managedObjectClassName]);

		[[self class] mergeDataObjects:dataObjects
					  withModelObjects:[modelObjects allObjects]
							modelClass:modelClass
				dataPrimaryKeyProperty:dataPrimaryKeyProperty
			   modelPrimaryKeyProperty:modelPrimaryKeyProperty
						 mergeSelector:mergeSelector
					 parentModelObject:modelObject
						   addSelector:addSelector
							 inContext:context];
	} else {
		LogWarn(@"Relationship with name '%@' does not exist or is not to-many", relationShip);
	}
}

@end


