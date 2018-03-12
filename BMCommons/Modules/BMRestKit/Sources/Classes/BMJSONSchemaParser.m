//
//  BMJSONSchemaParser.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/17/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMJSONSchemaParser.h>
#import <BMCommons/NSObject+BMCommons.h>
#import <BMCommons/NSDictionary+BMCommons.h>
#import <BMCommons/BMObjectMapping.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/NSString+BMCommons.h>
#import <BMCommons/BMLogging.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/NSArray+BMCommons.h>
#import <BMCommons/BMCore.h>

@interface BMJSONSchemaParser()

@property (nonatomic, strong) NSMutableDictionary *schemaLookupDict;
@property (nonatomic, strong) NSDictionary *rootSchemaDict;
@property (nonatomic, strong) NSString *rootSchemaId;
@property (nonatomic, strong) NSURL *schemaURL;

@end

@implementation BMJSONSchemaParser

static NSDictionary *jsonDataTypeDict = nil;
static NSDictionary *jsonFormatTypeDict = nil;
static NSDictionary *jsonFieldFormatDict = nil;

#define JS_ALL_OF @"allOf"
#define JS_ANY_OF @"anyOf"
#define JS_DEFINITIONS @"definitions"

#define JS_MULTIPLE_OF @"multipleOf" //int: valid if <instance count>/multipleOf is an integer
#define JS_MAXIMUM @"maximum" //max value
#define JS_EXCLUSIVE_MAXIMUM @"exclusiveMaximum" //bool
#define JS_MINIMUM @"minimum" //min value
#define JS_EXCLUSIVE_MINIMUM @"exclusiveMinimum" //bool

#define JS_MAX_LENGTH @"maxLength" //max string length: UINT
#define JS_MIN_LENGTH @"minLength" //min string length: UINT, default 0
#define JS_PATTERN @"pattern" //regex validation pattern

#define JS_UNIQUE_ITEMS @"uniqueItems"
#define JS_MIN_ITEMS @"minItems"
#define JS_MAX_ITEMS @"maxItems"
    
#define JS_READ_ONLY @"readOnly"

#define JS_PROPERTIES @"properties"
#define JS_REQUIRED @"required"
#define JS_ENUM @"enum"
#define JS_TYPE @"type"
#define JS_REF @"$ref"
#define JS_ID @"id"
#define JS_ITEMS @"items"
#define JS_TITLE @"title"
#define JS_FORMAT @"format"

#define JS_TYPE_OBJECT  @"object"
#define JS_TYPE_ARRAY @"array"
#define JS_TYPE_STRING @"string"
#define JS_TYPE_INTEGER @"integer"
#define JS_TYPE_NUMBER @"number"
#define JS_TYPE_BOOLEAN @"boolean"
#define JS_TYPE_NULL @"null"

#define JS_FORMAT_EMAIL @"email"
#define JS_FORMAT_DATETIME @"date-time"
#define JS_FORMAT_HOSTNAME @"hostname"
#define JS_FORMAT_IPV4 @"ipv4"
#define JS_FORMAT_IPV6 @"ipv6"
#define JS_FORMAT_URI @"uri"

+ (void)initialize {

    /*
     A JSON array.
     boolean
     A JSON boolean.
     integer
     A JSON number without a fraction or exponent part.
     number
     Any JSON number. Number includes integer.
     null
     The JSON null value.
     object
     A JSON object.
     string
     */
    
    if (jsonDataTypeDict == nil) {
        jsonDataTypeDict = @{
                             JS_TYPE_ARRAY : BM_FIELD_TYPE_ARRAY,
                             JS_TYPE_INTEGER : BM_FIELD_TYPE_INT,
                             JS_TYPE_NUMBER : BM_FIELD_TYPE_DOUBLE,
                             JS_TYPE_NULL : BM_FIELD_TYPE_OBJECT,
                             JS_TYPE_OBJECT : BM_FIELD_TYPE_OBJECT,
                             JS_TYPE_STRING : BM_FIELD_TYPE_STRING,
                             JS_TYPE_BOOLEAN : BM_FIELD_TYPE_BOOL
                             };
    }
    
    if (jsonFormatTypeDict == nil) {
        jsonFormatTypeDict = @{
                             JS_FORMAT_URI : BM_FIELD_TYPE_URL,
                             JS_FORMAT_DATETIME : BM_FIELD_TYPE_DATE,
                             };
    }
    
    if (jsonFieldFormatDict == nil) {
        jsonFieldFormatDict = @{
                                JS_FORMAT_URI: @(BMSchemaFieldFormatTypeURI),
                                JS_FORMAT_DATETIME: @(BMSchemaFieldFormatTypeDateTime),
                                JS_FORMAT_IPV4: @(BMSchemaFieldFormatTypeIPV4Address),
                                JS_FORMAT_IPV6: @(BMSchemaFieldFormatTypeIPV6Address),
                                JS_FORMAT_EMAIL: @(BMSchemaFieldFormatTypeEmailAddress),
                                JS_FORMAT_HOSTNAME: @(BMSchemaFieldFormatTypeHostname),
                                };
    }
}

#pragma mark - Protected

- (NSDictionary *)primitiveTypeDictionary {
    return jsonDataTypeDict;
}

- (BOOL)preProcessSchemaURLs:(NSArray *)schemaURLs withError:(NSError **)error {

    self.schemaLookupDict = [NSMutableDictionary new];

    //Pre convert all URLs to JSON data so they can be found by references
    for (NSURL *url in schemaURLs) {
        NSData *data = [NSData dataWithContentsOfURL:url options:0 error:error];
        if (data) {
            NSDictionary *schemaDict = [self schemaDictFromData:data url:url withError:error];
            if (schemaDict) {
                NSString *schemaId = [schemaDict bmValueForXPath:@"id" withClass:NSString.class];
                if (schemaId) {
                    self.schemaLookupDict[schemaId] = schemaDict;
                }
            } else {
                return NO;
            }
        } else {
            LogError(@"Could not read data from url '%@': %@", url, *error);
            return NO;
        }
    }
    return YES;
}

- (NSDictionary *)schemaDictFromData:(NSData *)schemaData url:(NSURL *)url withError:(NSError **)error {

    NSDictionary *schemaDict = nil;
    NSString *urlString = url.absoluteString;

    if (urlString != nil) {
        schemaDict = self.schemaLookupDict[urlString];

        if (schemaDict != nil) {
            return schemaDict;
        }
    }

    Class sbjsonClass = NSClassFromString(@"SBJSON");
    id jsonObject = nil;

    SEL objectFromJSONDataSelector = NSSelectorFromString(@"objectFromJSONData");

    if ([schemaData respondsToSelector:objectFromJSONDataSelector]) {
        BM_IGNORE_SELECTOR_LEAK_WARNING(
                jsonObject = [schemaData performSelector:objectFromJSONDataSelector withObject:nil];
        )
    } else if (sbjsonClass) {
        id jsonParser = [sbjsonClass new];

        SEL objectWithStringSelector = NSSelectorFromString(@"objectWithString:");
        if ([jsonParser respondsToSelector:objectWithStringSelector]) {
            NSString *jsonString = [[NSString alloc] initWithData:schemaData encoding:NSUTF8StringEncoding];
            BM_IGNORE_SELECTOR_LEAK_WARNING(
                    jsonObject = [jsonParser performSelector:objectWithStringSelector withObject:jsonString];
            )
        }
    }

    if (!jsonObject) {
        jsonObject = [NSJSONSerialization JSONObjectWithData:schemaData options:0 error:error];
    }

    schemaDict = [jsonObject bmCastSafely:[NSDictionary class]];

    if (schemaDict == nil && jsonObject != nil && error) {
        *error = [BMErrorHelper genericErrorWithDescription:[NSString stringWithFormat:@"Schema data does not have a root-level dictionary"]];
    }

    if (schemaDict != nil && urlString != nil) {
        self.schemaLookupDict[urlString] = schemaDict;
    }

    return schemaDict;
}

- (NSDictionary *)parseSchemaImpl:(NSData *)schemaData fromURL:(NSURL *)url objectMappings:(NSMutableDictionary *)objectMappings withError:(NSError *__autoreleasing *)error {
    
    NSDictionary *schemaDict = [self schemaDictFromData:schemaData url:url withError:error];
    NSString *rootElementName = @"";
    
    if (schemaDict) {
        self.rootSchemaDict = schemaDict;
        self.rootSchemaId = nil;
        self.schemaURL = url;
        BMSchemaFieldType fieldType = [self parseSchemaDict:schemaDict withName:rootElementName currentSchemaId:nil objectMapping:nil objectMappingDict:objectMappings
                                         addToFieldMappings:NO fieldTypeRef:nil error:error];
        BOOL containsDefinitions = [schemaDict bmObjectForKey:JS_DEFINITIONS ofClass:NSDictionary.class] != nil;
        if (fieldType != BMSchemaFieldTypeNone || containsDefinitions) {
            return objectMappings;
        }
    }
    return nil;
}

#pragma mark - Private

- (NSDictionary *)resolveDefinitionForRef:(NSString *)refId {
    NSRange range = [refId rangeOfString:@"#/"];
    if (range.location == NSNotFound) {
        //Not a valid definition reference
        return nil;
    }

    NSString *jsonPointer = [refId substringFromIndex:range.location + 1];
    NSString *uri = range.location == 0 ? nil : [refId substringToIndex:range.location];

    NSDictionary *schemaDict = self.rootSchemaDict;

    if (uri.length > 0 && ![uri isEqualToString:self.rootSchemaId]) {
        schemaDict = self.schemaLookupDict[uri];
    }

    NSDictionary *ret = [schemaDict bmValueForXPath:jsonPointer withClass:NSDictionary.class];
    return ret;
}

- (NSString *)fullUriFromBase:(NSString *)base andPointer:(NSString *)pointer {
    NSUInteger index1 = base.length;
    while (index1 > 0) {
        unichar c = [base characterAtIndex:index1 - 1];
        if (c != '#') {
            break;
        }
        index1--;
    }
    NSUInteger index2 = 0;
    while (index2 < pointer.length) {
        unichar c = [pointer characterAtIndex:index2];
        if (c != '#') {
            break;
        }
        index2++;
    }
    return [NSString stringWithFormat:@"%@#%@", [base substringToIndex:index1], [pointer substringFromIndex:index2]];
}

- (NSString *)resolveReference:(NSString *)reference relativeTo:(NSString *)currentSchemaId isDefinitionReference:(BOOL *)isDefinitionReference {
    static NSRegularExpression *uriExpression = nil;
    BM_DISPATCH_ONCE(^{
        uriExpression = [[NSRegularExpression alloc] initWithPattern:@"^[a-zA-Z0-9]+:.*$" options:0 error:nil];
        NSAssert(uriExpression != nil, @"Expected expression to be valid");
    });

    NSString *ret = nil;
    if (reference != nil) {
        if ([reference hasPrefix:@"#"]) {
            //JSONPointer within current schema
            if (currentSchemaId) {
                ret = [self fullUriFromBase:currentSchemaId andPointer:reference];
            }
        } else if ([uriExpression matchesInString:reference options:0 range:NSMakeRange(0, reference.length)].count == 1) {
            //Absolute schema Id
            ret = reference;
        } else if (currentSchemaId) {
            //Relative schema: resolve against parent of current schema
            NSRange range = [reference rangeOfString:@"#"];
            NSString *pathPart = nil;
            NSString *refPart = nil;
            if (range.location != NSNotFound) {
                pathPart = [reference substringToIndex:range.location];
                refPart = [reference substringFromIndex:range.location];
            } else {
                pathPart = reference;
            }

            NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:currentSchemaId];
            NSString *path = [[urlComponents path] stringByDeletingLastPathComponent];
            if (path == nil) {
                path = @"/";
            }
            urlComponents.path = [path stringByAppendingPathComponent:pathPart];
            ret = urlComponents.URL.absoluteString;
            if (refPart != nil) {
                ret = [ret stringByAppendingString:refPart];
            }
        }

        //Strip of trailing '#' identifier
        while ([ret hasSuffix:@"#"]) {
            ret = [ret substringToIndex:ret.length - 1];
        }
    }

    if (isDefinitionReference) {
        *isDefinitionReference = [ret containsString:@"#/"];
    }

    return ret;
}

- (BMSchemaFieldType)parseSchemaDict:(NSDictionary *)schemaDict
                            withName:(NSString *)theName
                     currentSchemaId:(NSString *)currentSchemaId
                       objectMapping:(BMObjectMapping *)objectMapping
                   objectMappingDict:(NSMutableDictionary *)objectMappingDict
                  addToFieldMappings:(BOOL)addToFieldMappings
                        fieldTypeRef:(NSString **)fieldTypeRef
                               error:(NSError **)error {

    NSString *schemaId = [self resolveReference:[schemaDict bmObjectForKey:JS_ID ofClass:NSString.class] relativeTo:currentSchemaId isDefinitionReference:NULL];
    if (schemaId != nil) {
        currentSchemaId = schemaId;
        if (self.rootSchemaId == nil) {
            self.rootSchemaId = schemaId;
        }
    }

    BOOL isDefinitionReference = NO;
    NSString *refId = [self resolveReference:[schemaDict bmObjectForKey:JS_REF ofClass:NSString.class] relativeTo:currentSchemaId isDefinitionReference:&isDefinitionReference];

    if (isDefinitionReference) {
        schemaDict = [self resolveDefinitionForRef:refId];

        if (schemaDict == nil) {
            LogWarn(@"Could not resolve definition reference: %@", refId);
            return BMSchemaFieldTypeNone;
        }

        refId = nil;
    }

    NSString *jsonType = [schemaDict bmObjectForKey:JS_TYPE ofClass:NSString.class];
    NSString *title = [schemaDict bmObjectForKey:JS_TITLE ofClass:NSString.class];
    NSDictionary *definitions = [schemaDict bmObjectForKey:JS_DEFINITIONS ofClass:NSDictionary.class];
    NSString *regexPattern = nil;
    NSString *fieldType = nil;
    NSArray *enumValues = nil;
    NSInteger minLength = 0;
    NSInteger maxLength = -1;
    BOOL uniqueItems = NO;
    NSInteger minItems = 0;
    NSInteger maxItems = -1;
    BOOL exclusiveMaximum = NO;
    BOOL exclusiveMinimum = NO;
    NSNumber *maximum = nil;
    NSNumber *minimum = nil;
    NSNumber *multipleOf = nil;
    BMSchemaFieldType schemaFieldType = BMSchemaFieldTypeNone;
    BMSchemaFieldFormatType fieldFormatType = BMSchemaFieldFormatTypeNone;
    BOOL readOnly = [[schemaDict bmObjectForKey:JS_READ_ONLY ofClass:NSNumber.class defaultValue:@NO] boolValue];

    if (refId != nil) {

        schemaFieldType = BMSchemaFieldTypeObjectReference;
        fieldType = refId;

    } else if ([jsonType isEqual:JS_TYPE_OBJECT]) {

        NSString *mappingId = schemaId;
        if (title == nil) {
            //Ignore object mappings without a title
            LogWarn(@"Object mapping without title is ignored for element name: %@", theName);
            return BMSchemaFieldTypeNone;
        }
        
        schemaFieldType = BMSchemaFieldTypeObject;
        
        NSArray *unionSchemas = [schemaDict bmObjectForKey:JS_ALL_OF ofClass:NSArray.class];
        NSMutableSet *requiredProperties = [NSMutableSet set];
        NSMutableDictionary *jsonProperties = [NSMutableDictionary dictionary];
        if (unionSchemas) {
            //Merge the properties
            for (id dict in unionSchemas) {
                //Ignore non properties for now
                NSDictionary *props = [[dict bmCastSafely:NSDictionary.class] bmObjectForKey:JS_PROPERTIES ofClass:NSDictionary.class];
                NSArray *requiredProps = [[dict bmCastSafely:NSDictionary.class] bmObjectForKey:JS_REQUIRED ofClass:NSArray.class];
                [jsonProperties addEntriesFromDictionary:props];
                [requiredProperties addObjectsFromArray:requiredProps];
            }
        } else {
            NSDictionary *props = [schemaDict bmObjectForKey:JS_PROPERTIES ofClass:NSDictionary.class];
            [jsonProperties addEntriesFromDictionary:props];
            NSArray *requiredProps = [schemaDict bmObjectForKey:JS_REQUIRED ofClass:NSArray.class];
            [requiredProperties addObjectsFromArray:requiredProps];
        }
        
        BMObjectMapping *om = [self objectMappingForProperties:jsonProperties withElementName:theName title:title
                                               currentSchemaId:currentSchemaId mappingId:mappingId objectMappingDict:objectMappingDict error:error];
        
        if (om == nil) {
            return BMSchemaFieldTypeNone;
        }
        
        for (BMFieldMapping *fm in om.fieldMappings) {
            fm.required = [requiredProperties containsObject:fm.mappingPath];
        }
        
        if (!objectMapping) {
            objectMapping = om;
            objectMapping.rootElement = YES;
        }
        
        fieldType = om.name;
        
    } else if ([jsonType isEqual:JS_TYPE_ARRAY]) {
        
        schemaFieldType = BMSchemaFieldTypeArray;
        
        NSDictionary *itemDict = [schemaDict bmObjectForKey:JS_ITEMS ofClass:[NSDictionary class]];
        
        BMSchemaFieldType retType = [self parseSchemaDict:itemDict withName:theName currentSchemaId:currentSchemaId objectMapping:objectMapping objectMappingDict:objectMappingDict addToFieldMappings:NO fieldTypeRef:&fieldType error:error];
        
        uniqueItems = [[schemaDict bmObjectForKey:JS_UNIQUE_ITEMS ofClass:[NSNumber class] defaultValue:@(NO)] boolValue];
        minItems = [[schemaDict bmObjectForKey:JS_MIN_ITEMS ofClass:[NSNumber class] defaultValue:@(0)] integerValue];
        maxItems = [[schemaDict bmObjectForKey:JS_MAX_ITEMS ofClass:[NSNumber class] defaultValue:@(-1)] integerValue];
        
        if (retType == BMSchemaFieldTypeNone) {
            return BMSchemaFieldTypeNone;
        }
        
        schemaFieldType |= retType;
    } else {
        fieldType = [self.primitiveTypeDictionary bmObjectForKey:jsonType ofClass:NSString.class];
        if ([fieldType isEqualToString:BM_FIELD_TYPE_STRING]) {
            NSString *format = [schemaDict bmObjectForKey:JS_FORMAT ofClass:NSString.class];
            NSString *formatFieldType = [jsonFormatTypeDict bmObjectForKey:format ofClass:NSString.class];
            if (formatFieldType != nil) {
                fieldType = formatFieldType;
            }
            fieldFormatType = (BMSchemaFieldFormatType)[[jsonFieldFormatDict bmObjectForKey:format ofClass:NSNumber.class] unsignedIntegerValue];
            regexPattern = [schemaDict bmObjectForKey:JS_PATTERN ofClass:NSString.class];
            minLength = [[schemaDict bmObjectForKey:JS_MIN_LENGTH ofClass:NSNumber.class defaultValue:@(0)] integerValue];
            maxLength = [[schemaDict bmObjectForKey:JS_MAX_LENGTH ofClass:NSNumber.class defaultValue:@(-1)] integerValue];
        } else if ([fieldType isEqualToString:BM_FIELD_TYPE_INT] || [fieldType isEqualToString:BM_FIELD_TYPE_DOUBLE]) {
            multipleOf = [schemaDict bmObjectForKey:JS_MULTIPLE_OF ofClass:NSNumber.class];
            minimum = [schemaDict bmObjectForKey:JS_MINIMUM ofClass:NSNumber.class];
            maximum = [schemaDict bmObjectForKey:JS_MAXIMUM ofClass:NSNumber.class];
            exclusiveMinimum = [[schemaDict bmObjectForKey:JS_EXCLUSIVE_MINIMUM ofClass:NSNumber.class] boolValue];
            exclusiveMaximum = [[schemaDict bmObjectForKey:JS_EXCLUSIVE_MAXIMUM ofClass:NSNumber.class] boolValue];
        }

        enumValues = [schemaDict bmObjectForKey:JS_ENUM ofClass:NSArray.class];
        schemaFieldType = BMSchemaFieldTypePrimitive;
    }
    
    if (fieldType == nil) {
        //Ignore object mappings without a title
        if (definitions == nil) {
            LogWarn(@"JSON type: '%@' is not supported by the BMRestKit framework for mapping with name: '%@' for object mapping: '%@'", jsonType, theName, objectMapping.name);
        }
        return BMSchemaFieldTypeNone;
    }
    
    if (addToFieldMappings) {
        NSString *mappingPath = theName;
        if ((schemaFieldType & BMSchemaFieldTypeObjectReference) == BMSchemaFieldTypeObjectReference) {
            //Add a temporary mapping: will be resolved when all parsing is done
            
            BMFieldMapping *fieldMapping = [BMFieldMapping new];
            fieldMapping.mappingPath = mappingPath;
            fieldMapping.objectMappingRefId = fieldType;
            fieldMapping.schemaFieldType = schemaFieldType;
            [objectMapping addFieldMapping:fieldMapping];
            
        } else {
            NSString *fieldDescriptor = [self fieldDescriptorForField:mappingPath type:fieldType fieldType:schemaFieldType];
            BMFieldMapping *fieldMapping = [[BMFieldMapping alloc] initWithFieldDescriptor:fieldDescriptor
                                                                               mappingPath:mappingPath];
            fieldMapping.minLength = minLength;
            fieldMapping.maxLength = maxLength;
            fieldMapping.pattern = regexPattern;
            fieldMapping.enumeratedValues = enumValues;
            fieldMapping.schemaFieldType = schemaFieldType;
            fieldMapping.schemaFieldFormatType = fieldFormatType;
            fieldMapping.uniqueItems = uniqueItems;
            fieldMapping.minItems = minItems;
            fieldMapping.maxItems = maxItems;
            fieldMapping.maximum = maximum;
            fieldMapping.minimum = minimum;
            fieldMapping.exclusiveMaximum = exclusiveMaximum;
            fieldMapping.exclusiveMinimum = exclusiveMinimum;
            fieldMapping.multipleOf = multipleOf;
            fieldMapping.readOnly = readOnly;
            [objectMapping addFieldMapping:fieldMapping];
        }
    }
    
    if (objectMapping != nil) {
        BMObjectMapping* existingObjectMapping = [objectMappingDict bmObjectForKey:objectMapping.name ofClass:BMObjectMapping.class];
        
        if (existingObjectMapping && !existingObjectMapping.rootElement && objectMapping.rootElement) {
            existingObjectMapping.rootElement = YES;
            existingObjectMapping.elementName = objectMapping.elementName;
        } else {
            [objectMappingDict setObject:objectMapping forKey:objectMapping.name];
        }
    }
    
    if (fieldTypeRef) {
        *fieldTypeRef = fieldType;
    }
    
    return schemaFieldType;
}

- (NSArray *)genericClassNamesFromString:(NSString *)classNameString {
    
    if (!classNameString) {
        return nil;
    }
    
    NSMutableArray *ret = [NSMutableArray array];
    
    NSMutableString *s = [NSMutableString stringWithString:classNameString];
    NSRange range1;
    NSRange range2;
    
    BOOL classFound;
    do {
        classFound = NO;
        NSString *className = nil;
        range1 = [s rangeOfString:@"<" options:NSBackwardsSearch];
        if (range1.location != NSNotFound) {
            range2 = [s rangeOfString:@">" options:0 range:NSMakeRange(range1.location, s.length - range1.location)];
            if (range2.location != NSNotFound && range2.location > range1.location) {
                className = [s substringWithRange:NSMakeRange(range1.location + 1, range2.location - range1.location - 1)];
                if (className.length > 0) {
                    [ret insertObject:className atIndex:0];
                    classFound = YES;
                    [s deleteCharactersInRange:NSMakeRange(range1.location, range2.location - range1.location + 1)];
                }
            }
        }
    } while (classFound);
    
    [ret insertObject:s atIndex:0];
    
    return ret;
}


- (BOOL)getObjectType:(NSString **)objectType namespace:(NSString **)namespace fromFQClassName:(NSString *)classNameString {
    
    classNameString = [classNameString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]{} \t\n"]];
    
    NSArray *classNameComponents = [classNameString componentsSeparatedByString:@","];
    if (classNameComponents.count > 1) {
        //Only parse the value type
        LogWarn(@"For dictionaries the key type is ignored and is always a string, key type found: %@", classNameComponents.firstObject);
    }
    classNameString = classNameComponents.lastObject;
    
    NSArray *genericClassNames = [self genericClassNamesFromString:classNameString];
    
    NSMutableString *className = [NSMutableString string];
    
    for (NSString *s in genericClassNames) {
        if (className.length > 0) {
            [className appendString:@"Of"];
        }
        
        NSRange range = [s rangeOfString:@"." options:NSBackwardsSearch];
        NSString *genericClassName = nil;
        if (range.location == NSNotFound || range.location >= s.length) {
            genericClassName = s;
        } else {
            genericClassName = [s substringFromIndex:(range.location + 1)];
        }
        [className appendString:genericClassName];
    }
    [className replaceOccurrencesOfString:@"$" withString:@"_" options:0 range:NSMakeRange(0, className.length)];
    
    BOOL parsedSuccessfully = NO;
    
    if (className.length > 0) {
        parsedSuccessfully = YES;
        
        NSRange range = [genericClassNames.firstObject rangeOfString:@"." options:NSBackwardsSearch];
        NSString *theNameSpace = nil;
        if (range.location != NSNotFound) {
            theNameSpace = [genericClassNames.firstObject substringToIndex:range.location];
        }
        if (objectType) {
            *objectType = className;
        }
        if (namespace) {
            *namespace = theNameSpace;
        }
    }
    return parsedSuccessfully;
}

- (BOOL)getObjectType:(NSString **)objectType namespace:(NSString **)namespace parentObjectType:(NSString **)parentObjectType parentNamespace:(NSString **)parentNamespace fromTitle:(NSString *)title {
    
    NSArray *components = [title componentsSeparatedByString:@":"];
    BOOL valid = components.count >= 1 && components.count <= 2;
    if (components.count >= 1) {
        valid = valid && [self getObjectType:objectType namespace:namespace fromFQClassName:[components objectAtIndex:0]];
    }
    if (components.count >= 2) {
        valid = valid && [self getObjectType:parentObjectType namespace:parentNamespace fromFQClassName:[components objectAtIndex:1]];
    }
    return valid;
}

- (BMObjectMapping *)objectMappingForProperties:(NSDictionary *)jsonProperties
                                withElementName:(NSString *)elementName
                                          title:(NSString *)title
                                currentSchemaId:(NSString *)currentSchemaId
                                      mappingId:(NSString *)mappingId
                              objectMappingDict:(NSMutableDictionary *)objectMappingDict
                                          error:(NSError **)error {
    NSString *mappingName = nil;
    NSString *parentMappingName = nil;
    
    if (!title) {
        mappingName = [self.mappableObjectClassResolver mappableObjectClassNameForObjectType:elementName namespace:nil];
        
    } else if ([self.mappableObjectClassResolver getMappableObjectClassName:&mappingName andParentClassName:&parentMappingName fromDescriptor:title]) {
        
    } else {
        if (error) {
            *error = [BMErrorHelper genericErrorWithDescription:[NSString stringWithFormat:@"Could not parse object mapping with title: %@", title]];
        }
        return nil;
    }

    BMObjectMapping *currentMapping = [[BMObjectMapping alloc] initWithName:mappingName];
    currentMapping.elementName = elementName;
    currentMapping.mappingId = mappingId;
    currentMapping.parentName = parentMappingName;
    
    for (NSString *propertyName in jsonProperties) {
        NSDictionary *propertyDict = [jsonProperties bmObjectForKey:propertyName ofClass:NSDictionary.class];
        if ([self parseSchemaDict:propertyDict withName:propertyName currentSchemaId:currentSchemaId objectMapping:currentMapping objectMappingDict:objectMappingDict addToFieldMappings:YES fieldTypeRef:nil error:error] == BMSchemaFieldTypeNone) {
            return nil;
        }
    }
    return currentMapping;
}


@end
