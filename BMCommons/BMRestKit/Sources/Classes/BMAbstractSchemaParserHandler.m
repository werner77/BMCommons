//
//  BMAbstractSchemaParserHandler.m
//  
//
//  Created by Werner Altewischer on 12/17/13.
//
//

#import "BMAbstractSchemaParserHandler.h"
#import <BMCore/NSString+BMCommons.h>
#import <BMRestKit/BMObjectMapping.h>
#import <BMCore/BMLogging.h>

@implementation BMAbstractSchemaParserHandler

static NSSet *reservedKeywords = nil;
static NSSet *reservedPrefixes = nil;

+ (void)initialize {
    if (!reservedPrefixes) {
        reservedPrefixes= [NSSet setWithObjects:
                           @"new",
                           @"copy",
                           @"alloc",
                           nil];
    }
    if (!reservedKeywords) {
        reservedKeywords = [NSSet setWithObjects:
                            @"void",
                            @"char",
                            @"short",
                            @"int",
                            @"long",
                            @"float",
                            @"double",
                            @"signed",
                            @"unsigned",
                            @"id",
                            @"const",
                            @"volatile",
                            @"in",
                            @"out",
                            @"inout",
                            @"bycopy",
                            @"byref",
                            @"oneway",
                            @"self",
                            @"super",
                            @"@interface",
                            @"@end",
                            @"@implementation",
                            @"@end",
                            @"@interface",
                            @"@end",
                            @"@implementation",
                            @"@end",
                            @"@protocol",
                            @"@end",
                            @"@class",
                            @"description",
                            @"default", 
                            @"error", //reserved for NSError return value
                            nil];
    }
}

- (NSSet *)reservedKeywords {
    return reservedKeywords;
}

- (NSSet *)reservedPrefixes {
    return reservedPrefixes;
}

- (NSDictionary *)primitiveTypeDictionary {
    return nil;
}

- (NSArray *)parseSchema:(NSData *)schemaData withError:(NSError **)error {
    NSDictionary *objectMappings = [self parseSchemaImpl:schemaData objectMappings:[NSMutableDictionary new] withError:error];
    return [self processObjectMappings:objectMappings];
}

- (NSArray *)parseSchemaPaths:(NSArray *)schemaPaths withError:(NSError **)error {
    NSMutableArray *urls = [NSMutableArray array];
    
    for (NSString *filePath in schemaPaths) {
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        if (fileURL) {
            [urls addObject:fileURL];
        } else {
            LogWarn(@"Ignoring invalid file path: %@", filePath);
        }
    }
    return [self parseSchemaURLs:urls withError:error];
}

- (NSArray *)parseSchemaURLs:(NSArray *)schemaURLs withError:(NSError **)error {
    NSError __autoreleasing *theError = nil;
    if (error == nil) {
        error = &theError;
    }
    NSMutableDictionary *objectMappings = [NSMutableDictionary dictionary];
    for (NSURL *url in schemaURLs) {
        LogInfo(@"Parsing data from schema at url: %@", url);
        NSData *data = [NSData dataWithContentsOfURL:url options:0 error:error];
        if (data) {
            if ([self parseSchemaImpl:data objectMappings:objectMappings withError:error]) {
                LogInfo(@"Successfully parsed schema data");
            } else {
                LogError(@"Could not parse schema from url '%@': %@", url, *error);
                return nil;
            }
        } else {
            LogError(@"Could not read data from url '%@': %@", url, *error);
            return nil;
        }
    }
    return [self processObjectMappings:objectMappings];
}


- (id)init {
    if ((self = [super init])) {
        
    }
    return self;
}

- (NSString *)mappingNameForObjectType:(NSString *)theName forNamespace:(NSString *)theNamespace {
    
    if (!theName) {
        return nil;
    }
    
    if (!theNamespace) {
        theNamespace = self.targetNamespace;
    }
    
    return [self.mappableObjectClassResolver mappableObjectClassNameForObjectType:theName namespace:theNamespace];	
}

- (NSString *)fieldDescriptorForField:(NSString *)field type:(NSString *)type fieldType:(BMSchemaFieldType)fieldType {
    
    BOOL isArray = (fieldType & BMSchemaFieldTypeArray) == BMSchemaFieldTypeArray;
    BOOL isUnique = (fieldType & BMSchemaFieldTypeUnique) == BMSchemaFieldTypeUnique;
    BOOL isObject = (fieldType & BMSchemaFieldTypeObject) == BMSchemaFieldTypeObject || (fieldType & BMSchemaFieldTypeObjectReference) == BMSchemaFieldTypeObjectReference;

    NSString *arrayType = nil;

    if (isArray) {
        if (isUnique) {
            arrayType = @"set";
        } else {
            arrayType = @"array";
        }
    }
	
	field = [field bmStringWithLowercaseFirstChar];
	
	if ([self.reservedKeywords containsObject:field]) {
		//Append a type string
		NSString *appendString = (isObject ? @"Object" : [type bmStringWithUppercaseFirstChar]);
		field = [field stringByAppendingString:appendString];
	}
    
    for (NSString *reservedPrefix in self.reservedPrefixes) {
        if ([field hasPrefix:reservedPrefix]) {
            field = [@"the" stringByAppendingString:[field bmStringWithUppercaseFirstChar]];
        }
    }
	
	if (isArray) {
		//Make fieldname plural
		if (![field hasSuffix:@"s"]) {
			if ([field hasSuffix:@"y"]) {
				field = [[field substringToIndex:(field.length - 1)] stringByAppendingString:@"ies"];
			} else {
				field = [field stringByAppendingString:@"s"];
			}
		}
	}
	
	NSString *fieldDescriptor = nil;
	if ([type isEqual:@"string"]) {
		//String is default
		if (isArray) {
			fieldDescriptor = [NSString stringWithFormat:@"%@:%@", field, arrayType];
		} else {
			fieldDescriptor = field;
		}
	} else {
		if (isArray) {
			fieldDescriptor = [NSString stringWithFormat:@"%@:%@(%@)", field, arrayType, type];
		} else {
			if (isObject) {
				fieldDescriptor = [NSString stringWithFormat:@"%@:object(%@)", field, type];
			} else {
				fieldDescriptor = [NSString stringWithFormat:@"%@:%@", field, type];
			}
		}
	}
	return fieldDescriptor;
}

- (void)eliminateDuplicateFieldMappingsFromObjectMappings:(NSDictionary *)objectMappings {
    for (NSString *mappingName in objectMappings) {
        BMObjectMapping *mapping = [objectMappings objectForKey:mappingName];
        
        //Eliminate duplicate field mappings in parent mappings
        NSString *parentName = mapping.parentName;
        while (parentName != nil) {
            BMObjectMapping *parentMapping = [objectMappings objectForKey:parentName];
            
            for (BMFieldMapping *fieldMapping in mapping.fieldMappings) {
                NSString *fieldName = fieldMapping.fieldName;
                
                for (BMFieldMapping *parentFieldMapping in parentMapping.fieldMappings) {
                    if ([fieldName isEqual:parentFieldMapping.fieldName]) {
                        //Duplicate field!
                        [mapping removeFieldMapping:fieldMapping];
                    }
                }
            }
            parentName = parentMapping.parentName;
        }
    }
}

- (void)resolveUninitializedFieldMappingsFromObjectMappings:(NSDictionary *)objectMappings {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (BMObjectMapping *mapping in objectMappings.allValues) {
        if (mapping.mappingId != nil) {
            [dict setObject:mapping forKey:mapping.mappingId];
        }
    }
    
    for (BMObjectMapping *mapping in objectMappings.allValues) {
        for (BMFieldMapping *fieldMapping in [NSArray arrayWithArray:mapping.fieldMappings]) {
            if (!fieldMapping.isInitialized) {
                //The field mapping points to a object reference by value: resolve that reference
                NSString *refId = fieldMapping.objectMappingRefId;
                
                if (refId == nil) {
                    LogWarn(@"No refId found for uninitialized field mapping with path: %@ for object mapping: %@", fieldMapping.mappingPath, mapping.name);
                } else {
                    BMObjectMapping *associatedObjectMapping = [dict objectForKey:refId];
                    
                    if (associatedObjectMapping != nil) {
                        
                        NSString *mappingPath = fieldMapping.mappingPath;
                        NSString *fieldType = associatedObjectMapping.name;
                        BMSchemaFieldType schemaFieldType = fieldMapping.schemaFieldType;
                        
                        NSString *fieldDescriptor = [self fieldDescriptorForField:mappingPath type:fieldType fieldType:schemaFieldType];
                        
                        NSError *error = nil;
                        if (![fieldMapping setFieldDescriptor:fieldDescriptor withError:&error]) {
                            LogWarn(@"Could not initialize field mapping from field descriptor: %@: %@", fieldDescriptor, error);
                        }
                    } else {
                        LogWarn(@"Could not find object mapping for ref ID: %@", refId);
                    }
                }
            }
            
            if (!fieldMapping.isInitialized) {
                LogWarn(@"Removing uninitialized field mapping with path: %@ for object mapping: %@", fieldMapping.mappingPath, mapping.name);
                [mapping removeFieldMapping:fieldMapping];
            }
        }
    }
}

- (NSArray *)processObjectMappings:(NSDictionary *)objectMappings {
    [self resolveUninitializedFieldMappingsFromObjectMappings:objectMappings];
    [self eliminateDuplicateFieldMappingsFromObjectMappings:objectMappings];
    return [objectMappings allValues];
}

- (NSDictionary *)parseSchemaImpl:(NSData *)schemaData objectMappings:(NSMutableDictionary *)objectMappings withError:(NSError *__autoreleasing *)error {
    //Should be implemented by sub classes
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
