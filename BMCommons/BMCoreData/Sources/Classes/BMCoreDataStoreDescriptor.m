//
//  BMCoreDataStoreDescriptor.m
//  BMCommons
//
//  Created by Werner Altewischer on 10/20/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMCoreDataStoreDescriptor.h"
#import "BMFileHelper.h"
#import <BMCore/BMCore.h>

#define FILE_EXT @".sqlite"

@implementation BMCoreDataStoreDescriptor

+ (BMCoreDataStoreDescriptor *)storeDescriptorWithName:(NSString *)storeName configuration:(NSString *)configuration modelDescriptors:(NSArray *)modelDescriptors {
    BMCoreDataStoreDescriptor *descriptor = [[self alloc] init];
    descriptor.storeName = storeName;
    descriptor.modelConfiguration = configuration;
    descriptor.modelDescriptors = modelDescriptors;
    return descriptor;
}

/** 
 Convenience method to return a descriptor for the default case in which there is one model within a store
 */
+ (BMCoreDataStoreDescriptor *)storeDescriptorWithModelName:(NSString *)modelName version:(NSInteger)version configuration:(NSString *)configuration {
    //Default: storeName equals modelName and version equals model version
    return [self storeDescriptorWithName:modelName configuration:configuration modelDescriptors:
            @[[BMCoreDataModelDescriptor modelDescriptorWithModelName:modelName version:version]]];
}


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [self init])) {
        self.storeName = [coder decodeObjectForKey:@"storeName"];
        self.modelDescriptors = [coder decodeObjectForKey:@"modelDescriptors"];
        self.modelConfiguration = [coder decodeObjectForKey:@"modelConfiguration"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_storeName forKey:@"storeName"];
    [coder encodeObject:_modelDescriptors forKey:@"modelDescriptors"];
    [coder encodeObject:_modelConfiguration forKey:@"modelConfiguration"];
}


- (NSString *)versionString {
    NSMutableString *string = [NSMutableString string];
    
    for (BMCoreDataModelDescriptor *modelDescriptor in self.modelDescriptors) {
        if (string.length > 0) {
            [string appendString:@"."];
        }
        [string appendFormat:@"%zd", modelDescriptor.modelVersion];
    }
    return string;
}

- (NSURL *)storeURL {
    NSString *configuration = self.modelConfiguration ? self.modelConfiguration : @"";
    
    NSMutableString *fileName = [NSMutableString string];
    
    [fileName appendString:self.storeName];
    [fileName appendString:configuration];
    [fileName appendString:self.versionString];
    [fileName appendString:FILE_EXT];
    
    return [NSURL fileURLWithPath:[[BMFileHelper documentsDirectory] stringByAppendingPathComponent:fileName]];
}

- (NSManagedObjectModel *)managedObjectModel {
    
    NSMutableArray *models = [NSMutableArray array];
    NSMutableArray *handledModelURLs = [NSMutableArray new];
    
    for (BMCoreDataModelDescriptor *modelDescriptor in self.modelDescriptors) {
        NSURL *modelURL = modelDescriptor.modelURL;
        if (modelURL && ![handledModelURLs containsObject:modelURL]) {
            LogInfo(@"Loading object model from URL: %@", modelURL);
            NSManagedObjectModel *theModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
            if (theModel) {
                [models addObject:theModel];
            }
            [handledModelURLs addObject:modelURL];
        }
    }
    return [NSManagedObjectModel modelByMergingModels:models];
}

+ (NSInteger)existingVersionForModelName:(NSString *)modelName configuration:(NSString *)configuration {
	NSArray *documents = [BMFileHelper listApplicationDocuments];
    if (configuration ==  nil) configuration = @"";
	const char *pattern = [[NSString stringWithFormat:@"%@%@%%d%@", modelName, configuration, FILE_EXT] cStringUsingEncoding:NSUTF8StringEncoding];
	
    NSString *nullVersionName = [NSString stringWithFormat:@"%@%@%@", modelName, configuration, FILE_EXT];
    
	int highestVersion = [documents containsObject:nullVersionName] ? 0 : -1;
	int version;
	for (NSString *document in documents) {
		if (sscanf([document cStringUsingEncoding:NSUTF8StringEncoding], pattern, &version) > 0 && version > highestVersion) {
			highestVersion = version;
		}
	}
	return highestVersion;
}

@end
