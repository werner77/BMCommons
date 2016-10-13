//
//  BMCoreDataApplicationContext.m
//  BMCommons
//
//  Created by Werner Altewischer on 7/13/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMCoreDataApplicationContext.h"
#import "BMCoreDataHelper.h"
#import "BMCoreDataStoreCollectionDescriptor.h"
#import "BMFileHelper.h"
#import <BMCommons/BMCore.h>

#define STORE_DESCRIPTOR_FILENAME @"storedescriptor.scd"

@interface BMCoreDataApplicationContext(Private)

- (NSString *)dataStoreCollectionDescriptorFilePath;
- (void)saveDataStoreCollectionDescriptor;
- (BMCoreDataStoreCollectionDescriptor *)buildCurrentStoreCollectionDescriptor;
- (BMCoreDataStoreCollectionDescriptor *)buildNewStoreCollectionDescriptor;

@end

@implementation BMCoreDataApplicationContext

@synthesize coreDataStack;


- (id)init {
	if ((self = [super init])) {
        
        BMCoreDataStoreCollectionDescriptor *datastoreCollectionDescriptor = [self dataStoreCollectionDescriptor];
        
        if (!datastoreCollectionDescriptor) {
            datastoreCollectionDescriptor = [self buildNewStoreCollectionDescriptor];
        }
        
        if (datastoreCollectionDescriptor) {
            coreDataStack = [[BMCoreDataStack alloc] initWithStoreCollectionDescriptor:datastoreCollectionDescriptor];
        }
    
	}
	return self;
}

- (void)dealloc {
	if (self.active) {
		[self terminate];
	}	
	BM_RELEASE_SAFELY(coreDataStack);    
}

#pragma mark -
#pragma mark Abstract methods

- (NSString *) coreDataModelName {
	return nil;
}

- (NSArray *)coreDataModelNames {
	return nil;
}

- (NSInteger)coreDataModelVersion {
	return -1;
}

- (NSArray *)coreDataModelVersions {
	return nil;
}

- (NSArray *)coreDataModelConfigurations {
	return nil;
}

- (BMCoreDataStoreCollectionDescriptor *)dataStoreCollectionDescriptor {
    return nil;
}

- (void)initialize {
    
	//Migrate the old model
	if (coreDataStack) {
        BMCoreDataStoreCollectionDescriptor *currentDescriptor = [self currentDataStoreCollectionDescriptor];
        BOOL migrationSucceeded = [coreDataStack migrateModel:YES withStoreCollectionDescriptor:currentDescriptor];
        if (!migrationSucceeded) {
            LogError(@"Could not migrate object model");
        } else {
            [self saveDataStoreCollectionDescriptor];
        }
        //Save the core data to initialize the core data file
        [coreDataStack flushWithCompletion:nil];
    }
    
    [super initialize];
}

- (void)save {
    [BMCoreDataHelper saveContext:[coreDataStack mainObjectContext] recursively:YES completionContext:nil completion:nil];
	[super save];
}

#pragma mark -
#pragma mark Protected methods

- (BMCoreDataStoreCollectionDescriptor *)currentDataStoreCollectionDescriptor {
    BMCoreDataStoreCollectionDescriptor *currentDescriptor = [BMCoreDataStoreCollectionDescriptor load:self.dataStoreCollectionDescriptorFilePath];
    
    if (!currentDescriptor) {
        currentDescriptor = [self buildCurrentStoreCollectionDescriptor];
        [currentDescriptor save:self.dataStoreCollectionDescriptorFilePath];
    }
    return currentDescriptor;
}

@end

@implementation BMCoreDataApplicationContext(Private)

- (NSString *)dataStoreCollectionDescriptorFilePath {
    return [BMFileHelper fullDocumentPath:STORE_DESCRIPTOR_FILENAME];
}

- (void)saveDataStoreCollectionDescriptor {
    [self.coreDataStack.storeCollectionDescriptor save:self.dataStoreCollectionDescriptorFilePath];
}

//Method for reverse engineering the data store descriptors from the existent datastore files (sqlite files). This code
//is needed for backwards compatibility of existing stores without a store descriptor file.
- (BMCoreDataStoreCollectionDescriptor *)buildCurrentStoreCollectionDescriptor {
    BMCoreDataStoreCollectionDescriptor *currentDescriptor = nil;
    //Try to create a descriptor from the current data store for backwards compatibility
    NSMutableArray *currentStoreDescriptors = [NSMutableArray array];
    
    for (BMCoreDataStoreDescriptor *storeDescriptor in self.coreDataStack.storeCollectionDescriptor.storeDescriptors) {
        
        //Convention was $modelName$modelConfiguration$modelVersion.sqlite
        NSString *configuration = storeDescriptor.modelConfiguration;
        if (configuration == nil) configuration = @"";
        
        NSMutableArray *currentModelDescriptors = [NSMutableArray array];
        NSDate *lastModificationDate = nil;
        NSString *latestStoreFile = nil;
        NSMutableArray *storeFiles = [NSMutableArray array];
        
        for (BMCoreDataModelDescriptor *modelDescriptor in storeDescriptor.modelDescriptors) {
            NSInteger existingVersion = [BMCoreDataStoreDescriptor existingVersionForModelName:modelDescriptor.modelName configuration:storeDescriptor.modelConfiguration];
            
            if (existingVersion >= 0) {
                BMCoreDataModelDescriptor *currentModelDescriptor = [BMCoreDataModelDescriptor modelDescriptorWithModelName:modelDescriptor.modelName version:existingVersion];
                
                NSString *filename = [NSString stringWithFormat:@"%@%@%zd.sqlite", modelDescriptor.modelName, configuration, existingVersion];
                NSString *filePath = [BMFileHelper fullDocumentPath:filename];
                
                [storeFiles addObject:filePath];
                
                // Get file size
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
                if(fileAttributes != nil) {
                    
                    NSDate *modificationDate = fileAttributes[NSFileModificationDate];
                    
                    if (lastModificationDate == nil || [modificationDate compare:lastModificationDate] == NSOrderedDescending) {
                        latestStoreFile = filePath;
                        lastModificationDate = modificationDate;
                    }
                }
                
                [currentModelDescriptors addObject:currentModelDescriptor];
            }
        }
        
        if (currentModelDescriptors.count > 0) {
            BMCoreDataStoreDescriptor *currentStoreDescriptor = [BMCoreDataStoreDescriptor storeDescriptorWithName:storeDescriptor.storeName
                                                                                                     configuration:storeDescriptor.modelConfiguration
                                                                                                  modelDescriptors:currentModelDescriptors];
            //Remove all the files but the biggest: the other ones don't contain data
            for (NSString *filepath in storeFiles) {
                if (![filepath isEqual:latestStoreFile]) {
                    [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
                }
            }
            
            if (latestStoreFile) {
                NSString *newPath = [[currentStoreDescriptor storeURL] path];
                [[NSFileManager defaultManager] moveItemAtPath:latestStoreFile toPath:newPath error:nil];
            }
            [currentStoreDescriptors addObject:currentStoreDescriptor];
        }
    }
    currentDescriptor = [BMCoreDataStoreCollectionDescriptor storeCollectionDescriptorWithStoreDescriptors:currentStoreDescriptors];
    return currentDescriptor;
}

- (BMCoreDataStoreCollectionDescriptor *)buildNewStoreCollectionDescriptor {
    //Legacy code: for backwards compatibility.
    BMCoreDataStoreCollectionDescriptor *datastoreCollectionDescriptor = nil;
    
    if ([self coreDataModelName] && self.coreDataModelNames) {
        NSException *exception = [NSException exceptionWithName:@"InvalidArgumentException" reason:@"Only supply coreDateModelName or coreDateModelNames, not both" userInfo:nil];
        @throw exception;
    }
    
    NSArray *modelNames = nil;
    NSArray *modelVersions = nil;
    
    NSArray *modelConfigurations = [self coreDataModelConfigurations];
    NSString *modelName = [self coreDataModelName];
    NSInteger modelVersion = [self coreDataModelVersion];
    if (modelName) {
        modelNames = @[modelName];
        modelVersions = @[@(modelVersion)];
    } else {
        modelNames = [NSArray arrayWithArray:[self coreDataModelNames]];
        modelVersions = [NSArray arrayWithArray:[self coreDataModelVersions]];
    }
    
    if (modelNames.count != modelVersions.count) {
        NSException *exception = [NSException exceptionWithName:@"InvalidArgumentException" reason:@"Model versions count should match model names count" userInfo:nil];
        @throw exception;
    }
    
    if (modelNames.count > 0 && modelVersions.count > 0) {
        if (modelNames.count > 0 && modelConfigurations.count == 0) {
            
            NSMutableArray *modelDescriptors = [NSMutableArray array];
            
            NSMutableString *storeName = [NSMutableString string];
            
            for (int i = 0; i < modelNames.count; ++i) {
                NSString *modelName = modelNames[i];
                NSNumber *modelVersion = modelVersions[i];
                BMCoreDataModelDescriptor *modelDescriptor = [BMCoreDataModelDescriptor modelDescriptorWithModelName:modelName version:[modelVersion integerValue]];
                [modelDescriptors addObject:modelDescriptor];
                
                [storeName appendString:modelName];
            }
            
            BMCoreDataStoreDescriptor *storeDescriptor = [BMCoreDataStoreDescriptor storeDescriptorWithName:storeName configuration:nil modelDescriptors:modelDescriptors];
            
            datastoreCollectionDescriptor = [BMCoreDataStoreCollectionDescriptor storeCollectionDescriptorWithStoreDescriptors:@[storeDescriptor]];
            
            
        } else if (modelNames.count == 1 && modelVersions.count == 1 && modelConfigurations.count > 0) {
            
            NSString *modelName = modelNames[0];
            NSInteger modelVersion = [modelVersions[0] integerValue];
            
            NSMutableArray *storeDescriptors = [NSMutableArray array];
            
            for (NSString *configuration in modelConfigurations) {
                BMCoreDataStoreDescriptor *storeDescriptor = [BMCoreDataStoreDescriptor storeDescriptorWithModelName:modelName version:modelVersion configuration:configuration];
                [storeDescriptors addObject:storeDescriptor];
            }
            
            datastoreCollectionDescriptor = [BMCoreDataStoreCollectionDescriptor storeCollectionDescriptorWithStoreDescriptors:storeDescriptors];
            
        } else {
            //Illegal
            NSException *exception = [NSException exceptionWithName:@"InvalidArgumentException" reason:@"Invalid combination of modelNames and modelConfigurations supplied. Either supply multiple model names or multiple configurations but not both." userInfo:nil];
            @throw exception;
        }
    }
    
    return datastoreCollectionDescriptor;
}

@end
