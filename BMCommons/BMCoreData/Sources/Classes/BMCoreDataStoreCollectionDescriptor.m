//
//  BMCoreDataStoreCollectionDescriptor.m
//  BMCommons
//
//  Created by Werner Altewischer on 10/20/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMCoreDataStoreCollectionDescriptor.h"
#import <BMCore/BMCore.h>

@implementation BMCoreDataStoreCollectionDescriptor

+ (BMCoreDataStoreCollectionDescriptor *)storeCollectionDescriptorWithStoreDescriptors:(NSArray *)theStoreDescriptors {
    BMCoreDataStoreCollectionDescriptor *descriptor = [BMCoreDataStoreCollectionDescriptor new];
    descriptor.storeDescriptors = theStoreDescriptors;
    return descriptor;
}

+ (BMCoreDataStoreCollectionDescriptor *)load:(NSString *)filePath {
    BMCoreDataStoreCollectionDescriptor *descriptor = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return descriptor;
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
        self.storeDescriptors = [coder decodeObjectForKey:@"storeDescriptors"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.storeDescriptors forKey:@"storeDescriptors"];
}


- (BOOL)save:(NSString *)filePath {
    return [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

- (BMCoreDataStoreDescriptor *)storeDescriptorByName:(NSString *)storeName {
    BMCoreDataStoreDescriptor *theStoreDescriptor = nil;
    for (BMCoreDataStoreDescriptor *storeDescriptor in self.storeDescriptors) {
        if ([storeDescriptor.storeName isEqual:storeName]) {
            theStoreDescriptor = storeDescriptor;
            break;
        }
    }
    return theStoreDescriptor;
}

- (NSManagedObjectModel *)managedObjectModel {
    
    NSMutableArray *models = [NSMutableArray array];
    NSMutableArray *handledModelURLs = [NSMutableArray new];
    for (BMCoreDataStoreDescriptor *storeDescriptor in self.storeDescriptors) {
        for (BMCoreDataModelDescriptor *modelDescriptor in storeDescriptor.modelDescriptors) {
            NSURL *modelURL = modelDescriptor.modelURL;
            if (![handledModelURLs containsObject:modelURL]) {
                LogInfo(@"Loading object model from URL: %@", modelURL);
                NSManagedObjectModel *theModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
                [models addObject:theModel];
                [handledModelURLs addObject:modelURL];
            }
        }
    }
    return [NSManagedObjectModel modelByMergingModels:models];
}


@end
