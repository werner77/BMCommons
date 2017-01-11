//
//  BMMappableObjectGenerator.h
//  BMCommons
//
//  Created by Werner Altewischer on 2/10/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMMGTemplateEngine.h>

typedef NS_ENUM(NSUInteger, BMMappableObjectSchemaType) {
    BMMappableObjectSchemaTypeXSD = 0,
    BMMappableObjectSchemaTypeJSON = 1
};

/**
 Class that generates mappable objects using MGTemplateEngine from an xsd.
 */
@interface BMMappableObjectGenerator : NSObject<BMMGTemplateEngineDelegate> {
    @private
	NSString *outputDir;
	NSString *classNameSuffix;
	NSString *headerTemplatePath;
	NSString *implementationTemplatePath;
	NSString *mappingVariableName;	
	NSString *customHeaderTemplatePath;
	NSString *customImplementationTemplatePath;
	NSDictionary *namespacePrefixMappings;
    BOOL removeOldFiles;
    BMMappableObjectSchemaType schemaType;
}

/**
 The output directory to write to.
 */
@property (nonatomic, strong) NSString *outputDir;

/**
 Suffix to append to the output classnames.
 */
@property (nonatomic, strong) NSString *classNameSuffix;

/**
 Prefix to prepend to the output classnames, even before any namespace prefixes.
 */
@property (nonatomic, strong) NSString *classNamePrefix;

/**
 Path to the template for the machine generated header file.
 */
@property (nonatomic, strong) NSString *headerTemplatePath;

/**
 Path to the template for the machine generated implementation file.
 */
@property (nonatomic, strong) NSString *implementationTemplatePath;

/**
 Name of the variable to publish BMObjectMapping under for the MGTemplateEngine generation. Default is 'mapping'
 */
@property (nonatomic, strong) NSString *mappingVariableName;

/**
 Path to the template for the customizable generated header file.
 */
@property (nonatomic, strong) NSString *customHeaderTemplatePath;

/**
 Path to the template for the customizable generated implementation file.
 */
@property (nonatomic, strong) NSString *customImplementationTemplatePath;

/**
 Dictionary for mapping namespace URLs (keys) to classname prefixes (values).
 */
@property (nonatomic, strong) NSDictionary *namespacePrefixMappings;

/**
 If true remove old generated files (only files beginning with '_') that are no longer valid.
 */
@property (nonatomic, assign) BOOL removeOldFiles;

/**
 Uses the modification date for the files involved to determine if a write is necessary or not.
 */
@property (nonatomic, assign) BOOL useModificationDateCheck;

/**
 * Set to true to enable swift output instead of objc
 */
@property (nonatomic, assign) BOOL swiftMode;

/**
 The kind of schema that is expected as input. 
 
 Default is XSD.
 */
@property (nonatomic, assign) BMMappableObjectSchemaType schemaType;

/**
 Start generating using the schema at the specified filePath.
 */
- (BOOL)generateFromSchema:(NSString *)schemaPath withError:(NSError **)error;

/**
 Start generating using the schema at the specified filePath.
 */
- (BOOL)generateFromSchemas:(NSArray *)schemaPaths withError:(NSError **)error;

@end
