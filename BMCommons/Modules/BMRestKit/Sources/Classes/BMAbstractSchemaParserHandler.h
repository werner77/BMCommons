//
//  BMAbstractSchemaParserHandler.h
//  
//
//  Created by Werner Altewischer on 12/17/13.
//
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMSchemaFieldType.h>
#import <BMCommons/BMMappableObjectClassResolver.h>

@interface BMAbstractSchemaParserHandler : NSObject 

//Namespace to return if targetNamespace == nil
@property (nonatomic, strong) NSString *defaultNamespace;
@property (nonatomic, strong) NSString *targetNamespace;
@property (nonatomic, strong) id <BMMappableObjectClassResolver> mappableObjectClassResolver;

@property (nonatomic, readonly) NSSet *reservedKeywords;
@property (nonatomic, readonly) NSSet *reservedPrefixes;
@property (nonatomic, readonly) NSDictionary *primitiveTypeDictionary;

- (NSArray *)parseSchema:(NSData *)schemaData withError:(NSError **)error;
- (NSArray *)parseSchemaPaths:(NSArray *)schemaPaths withError:(NSError **)error;
- (NSArray *)parseSchemaURLs:(NSArray *)schemaURLs withError:(NSError **)error;

@end

@interface BMAbstractSchemaParserHandler(Protected)

- (NSString *)mappingNameForObjectType:(NSString *)theName forNamespace:(NSString *)theNamespace;
- (NSString *)fieldDescriptorForField:(NSString *)field type:(NSString *)type fieldType:(BMSchemaFieldType)fieldType;
- (void)eliminateDuplicateFieldMappingsFromObjectMappings:(NSDictionary *)objectMappings;
- (NSArray *)processObjectMappings:(NSDictionary *)objectMappings;
- (void)resolveUninitializedFieldMappingsFromObjectMappings:(NSDictionary *)objectMappings;

//Main method to be implemented by sub classes
- (NSDictionary *)parseSchemaImpl:(NSData *)schemaData objectMappings:(NSMutableDictionary *)objectMappings withError:(NSError *__autoreleasing *)error;

@end
