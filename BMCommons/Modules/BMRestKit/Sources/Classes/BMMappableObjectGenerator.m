//
//  BMMappableObjectGenerator.m
//  BMCommons
//
//  Created by Werner Altewischer on 2/10/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMMappableObjectGenerator.h>
#import <BMCommons/BMFileHelper.h>
#import <BMCommons/BMObjectMapping.h>
#import <BMCommons/BMXMLParser.h>
#import <BMCommons/BMXMLSchemaParser.h>
#import <BMCommons/BMICUTemplateMatcher.h>
#import <BMCommons/BMJSONSchemaParser.h>
#import <BMCommons/BMErrorHelper.h>
#import <BMCommons/BMRestKit.h>
#import <BMCommons/BMJavaBasedMappableObjectClassResolver.h>

typedef NS_ENUM(NSUInteger, BMFileType) {
    BMFileTypeObjCHeader,
    BMFileTypeObjCImplementation,
    BMFileTypeSwift
};

@interface BMMappableObjectGenerator(Private)

- (BOOL)writeFileFromTemplate:(NSString *)templatePath objectMapping:(BMObjectMapping *)objectMapping fileType:(BMFileType)fileType custom:(BOOL)custom referenceDate:(NSDate *)referenceDate outputFile:(NSString **)outputFile error:(NSError **)error;
- (NSDate *)lastModificationDateForFiles:(NSArray *)files;
- (NSDate *)modificationDateForFile:(NSString *)path;

@end

@implementation BMMappableObjectGenerator {
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

@synthesize outputDir, classNameSuffix, classNamePrefix;
@synthesize headerTemplatePath, implementationTemplatePath;
@synthesize customHeaderTemplatePath, customImplementationTemplatePath;
@synthesize mappingVariableName;
@synthesize namespacePrefixMappings;
@synthesize removeOldFiles;
@synthesize schemaType;

- (id)init {
	if ((self = [super init])) {

		self.mappingVariableName = @"mapping";
        self.schemaType = BMMappableObjectSchemaTypeXSD;
	}
	return self;
}

- (BOOL)generateFromSchema:(NSString *)schemaPath withError:(NSError *__autoreleasing *)error {
    return [self generateFromSchemas:@[schemaPath] withError:error];
}

- (BOOL)generateFromSchemas:(NSArray *)schemaPaths withError:(NSError *__autoreleasing *)errorOut {
	
    BOOL classChecksEnabled = [BMFieldMapping isClassChecksEnabled];
    [BMFieldMapping setClassChecksEnabled:NO];
    
    NSArray *objectMappings = nil;
    NSError *error = nil;
    
    BMAbstractMappableObjectClassResolver *classResolver = [BMJavaBasedMappableObjectClassResolver new];
    classResolver.swiftMode = self.swiftMode;
    classResolver.namespacePrefixMappings = self.namespacePrefixMappings;
    classResolver.defaultModule = self.defaultModule;
    classResolver.classNamePrefix = self.classNamePrefix;
    classResolver.classNameSuffix = self.classNameSuffix;

    BMAbstractSchemaParserHandler *parser = nil;

    if (self.schemaType == BMMappableObjectSchemaTypeXSD) {
        parser = [[BMXMLSchemaParser alloc] initWithMappableObjectClassResolver:classResolver];
    } else if (self.schemaType == BMMappableObjectSchemaTypeJSON){
        parser = [[BMJSONSchemaParser alloc] initWithMappableObjectClassResolver:classResolver];
    }

    parser.defaultNamespace = self.defaultNamespace;
    objectMappings = [parser parseSchemaPaths:schemaPaths withError:&error];
    
    NSDate *referenceDate = nil;
    if (self.useModificationDateCheck) {
        NSMutableArray *files = [NSMutableArray array];
        [files addObjectsFromArray:schemaPaths];
        [files bmSafeAddObject:self.headerTemplatePath];
        [files bmSafeAddObject:self.implementationTemplatePath];
        [files bmSafeAddObject:self.customHeaderTemplatePath];
        [files bmSafeAddObject:self.customImplementationTemplatePath];
        
        referenceDate = [self lastModificationDateForFiles:files];
    }
    
    if (objectMappings) {
        NSMutableArray *generatedFiles = [NSMutableArray array];
        
        int numberOfFilesWritten = 0;

        for (BMObjectMapping *objectMapping in objectMappings) {
            NSString *outputFile;

            if (self.swiftMode) {
                if ([self writeFileFromTemplate:self.implementationTemplatePath objectMapping:objectMapping fileType:BMFileTypeSwift custom:NO referenceDate:referenceDate outputFile:&outputFile error:&error]) numberOfFilesWritten++;
                if (outputFile) [generatedFiles addObject:outputFile];
                if ([self writeFileFromTemplate:self.customImplementationTemplatePath objectMapping:objectMapping fileType:BMFileTypeSwift custom:YES referenceDate:referenceDate outputFile:&outputFile error:&error]) numberOfFilesWritten++;
            } else {
                if ([self writeFileFromTemplate:self.headerTemplatePath objectMapping:objectMapping fileType:BMFileTypeObjCHeader custom:NO referenceDate:referenceDate outputFile:&outputFile error:&error]) numberOfFilesWritten++;
                if (outputFile) [generatedFiles addObject:outputFile];
                if ([self writeFileFromTemplate:self.implementationTemplatePath objectMapping:objectMapping fileType:BMFileTypeObjCImplementation custom:NO referenceDate:referenceDate outputFile:&outputFile error:&error]) numberOfFilesWritten++;
                if (outputFile) [generatedFiles addObject:outputFile];
                if ([self writeFileFromTemplate:self.customHeaderTemplatePath objectMapping:objectMapping fileType:BMFileTypeObjCHeader custom:YES referenceDate:referenceDate outputFile:&outputFile error:&error]) numberOfFilesWritten++;
                if ([self writeFileFromTemplate:self.customImplementationTemplatePath objectMapping:objectMapping fileType:BMFileTypeObjCImplementation custom:YES referenceDate:referenceDate outputFile:&outputFile error:&error]) numberOfFilesWritten++;
            }

            if (error != nil) {
                break;
            }
        }
        
        if (error == nil && self.removeOldFiles) {
            NSFileManager *fm = [NSFileManager defaultManager];
            NSArray *allItems = [fm contentsOfDirectoryAtPath:self.outputDir error:nil];
            NSMutableArray *filesToRemove = [NSMutableArray array];
            
            for (NSString *filename in allItems) {
                if ([filename hasPrefix:@"_"] && ([filename hasSuffix:@".m"] || [filename hasSuffix:@".h"]) && ![generatedFiles containsObject:filename]) {
                    NSString *underscoreFile = [self.outputDir stringByAppendingPathComponent:filename];
                    NSString *nonUnderscoreFile = [self.outputDir stringByAppendingPathComponent:[filename substringFromIndex:1]];
                    NSDictionary *underscoreAttributes = [fm attributesOfItemAtPath:underscoreFile error:nil];
                    NSDictionary *nonUnderscoreAttributes = [fm attributesOfItemAtPath:nonUnderscoreFile error:nil];
                    
                    NSDate *underscoreModificationDate = [underscoreAttributes fileModificationDate];
                    NSDate *nonUnderscoreModificationDate = [nonUnderscoreAttributes fileModificationDate];
                    
                    if (underscoreModificationDate && nonUnderscoreModificationDate) {
                        NSTimeInterval timeInterval = [nonUnderscoreModificationDate timeIntervalSinceDate:underscoreModificationDate];
                        if (ABS(timeInterval) < 10.0) {
                            [filesToRemove addObject:nonUnderscoreFile];
                        }
                    }
                    [filesToRemove addObject:underscoreFile];
                }
            }
            
            for (NSString *filePath in filesToRemove) {
                [fm removeItemAtPath:filePath error:nil];
            }
        }
        
        if (error != nil) {
            LogError(@"Bailed out because of file writing error: %@", error);
        }
        LogInfo(@"Wrote %d file(s)", numberOfFilesWritten);
    } else {
        LogError(@"Could not parse schema: %@", error);
    }
    
    [BMFieldMapping setClassChecksEnabled:classChecksEnabled];
    
    if (errorOut) {
        *errorOut = error;
    }
    return (error == nil);
}

#pragma mark -
#pragma mark MGTemplateEngine delegate implementation

- (void)templateEngine:(BMMGTemplateEngine *)engine blockStarted:(NSDictionary *)blockInfo {
	
}

- (void)templateEngine:(BMMGTemplateEngine *)engine blockEnded:(NSDictionary *)blockInfo {
	
}

- (void)templateEngineFinishedProcessingTemplate:(BMMGTemplateEngine *)engine {
	
}

- (void)templateEngine:(BMMGTemplateEngine *)engine encounteredError:(NSError *)error isContinuing:(BOOL)continuing {
	
}

@end

@implementation BMMappableObjectGenerator(Private)

- (NSDate *)lastModificationDateForFiles:(NSArray *)files {
    NSDate *ret = nil;
    for (NSString *file in files) {
        NSDate *modificationDate = [self modificationDateForFile:file];
        if (modificationDate != nil && (ret == nil || [modificationDate timeIntervalSinceDate:ret] > 0)) {
            ret = modificationDate;
        }
    }
    return ret;
}

- (NSDate *)modificationDateForFile:(NSString *)path {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    NSDate *fileModificationDate = [fileAttributes objectForKey:NSFileModificationDate];
    return fileModificationDate;
}

- (BOOL)writeFileFromTemplate:(NSString *)templatePath objectMapping:(BMObjectMapping *)objectMapping fileType:(BMFileType)fileType custom:(BOOL)custom referenceDate:(NSDate *)referenceDate outputFile:(NSString **)outputFile error:(NSError **)error {
	NSString *extension = fileType == BMFileTypeSwift ? @"swift" : ( fileType == BMFileTypeObjCHeader ? @"h" : @"m");
	NSString *fileName = custom ? [NSString stringWithFormat:@"%@.%@", objectMapping.unqualifiedObjectClassName, extension] : [NSString stringWithFormat:@"_%@.%@", objectMapping.unqualifiedObjectClassName, extension];
	NSString *path = [self.outputDir stringByAppendingPathComponent:fileName];
    
    if (outputFile) {
        *outputFile = fileName;
    }
	
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    BOOL shouldWrite = !custom || !fileExists;
	NSString *currentContents = nil;
	
	if (!custom && fileExists) {
        if (referenceDate != nil) {
            NSDate *fileModificationDate = [self modificationDateForFile:path];
            if (fileModificationDate != nil && [fileModificationDate timeIntervalSinceDate:referenceDate] > 0) {
                shouldWrite = NO;
            }
        } else {
            currentContents = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding];
        }
	}
	
	BOOL written = NO;
	
	if (shouldWrite) {
		BMMGTemplateEngine *engine = [BMMGTemplateEngine templateEngine];
		[engine setDelegate:self];
		[engine setMatcher:[BMICUTemplateMatcher matcherWithTemplateEngine:engine]];
		
		NSString *result = [engine processTemplateInFileAtPath:templatePath 
												 withVariables:[NSDictionary dictionaryWithObject:objectMapping forKey:self.mappingVariableName]];
		
        if (result) {
            if (!currentContents || ![currentContents isEqual:result]) {
                LogInfo(@"Writing file: %@", path);
                written = [[result dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path options:NSDataWritingAtomic error:error];
            }
        } else {
            NSString *message = [NSString stringWithFormat:@"Template could not be processed, no file written at path: %@", path];
            LogWarn(@"%@", message);
            if (error) {
                *error = [BMErrorHelper errorForDomain:@"BMMappableObjectGenerator" code:10 description:message];
            }
        }
	}
	return written;
}

@end
