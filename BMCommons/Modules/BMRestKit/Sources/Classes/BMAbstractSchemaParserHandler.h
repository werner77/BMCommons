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

NS_ASSUME_NONNULL_BEGIN

@interface BMAbstractSchemaParserHandler : NSObject 

//Namespace to return if targetNamespace == nil
@property (nullable, nonatomic, strong) NSString *defaultNamespace;
@property (nullable, nonatomic, strong) NSString *targetNamespace;
@property (nullable, nonatomic, strong) id <BMMappableObjectClassResolver> mappableObjectClassResolver;

@property (nullable, nonatomic, readonly) NSSet *reservedKeywords;
@property (nullable, nonatomic, readonly) NSSet *reservedPrefixes;
@property (nullable, nonatomic, readonly) NSDictionary *primitiveTypeDictionary;

- (nullable NSArray *)parseSchema:(NSData *)schemaData withError:(NSError *_Nullable*_Nullable)error;
- (nullable NSArray *)parseSchemaPaths:(NSArray *)schemaPaths withError:(NSError *_Nullable*_Nullable)error;
- (nullable NSArray *)parseSchemaURLs:(NSArray *)schemaURLs withError:(NSError * _Nullable * _Nullable)error;

- (instancetype)initWithMappableObjectClassResolver:(id <BMMappableObjectClassResolver>)mappableObjectClassResolver NS_DESIGNATED_INITIALIZER;

@end

@interface BMAbstractSchemaParserHandler(Protected)

- (nullable NSString *)mappingNameForObjectType:(NSString *)theName forNamespace:(nullable NSString *)theNamespace;
- (NSString *)fieldDescriptorForField:(NSString *)field type:(NSString *)type fieldType:(BMSchemaFieldType)fieldType;
- (void)eliminateDuplicateFieldMappingsFromObjectMappings:(NSDictionary *)objectMappings;
- (NSArray *)processObjectMappings:(NSDictionary *)objectMappings;
- (void)resolveUninitializedFieldMappingsFromObjectMappings:(NSDictionary *)objectMappings;

//Main method to be implemented by sub classes
- (nullable NSDictionary *)parseSchemaImpl:(NSData *)schemaData objectMappings:(NSMutableDictionary *)objectMappings withError:(NSError *_Nullable __autoreleasing * _Nullable)error;

@end

NS_ASSUME_NONNULL_END

