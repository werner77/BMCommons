//
//  BMCoreDataStoreCollectionDescriptor.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/20/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCoreData/BMCoreDataStoreDescriptor.h>

@interface BMCoreDataStoreCollectionDescriptor : NSObject<NSCoding> 

@property (nonatomic, strong) NSArray *storeDescriptors;

+ (BMCoreDataStoreCollectionDescriptor *)storeCollectionDescriptorWithStoreDescriptors:(NSArray *)theStoreDescriptors;
+ (BMCoreDataStoreCollectionDescriptor *)load:(NSString *)filePath;

- (BMCoreDataStoreDescriptor *)storeDescriptorByName:(NSString *)storeName;
- (NSManagedObjectModel *)managedObjectModel;

- (BOOL)save:(NSString *)filePath;

@end
