//
//  BMCoreDataStoreCollectionDescriptor.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/20/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreDataStoreDescriptor.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMCoreDataStoreCollectionDescriptor : NSObject<NSCoding> 

@property (nullable, nonatomic, strong) NSArray *storeDescriptors;

+ (BMCoreDataStoreCollectionDescriptor *)storeCollectionDescriptorWithStoreDescriptors:(NSArray *)theStoreDescriptors;
+ (nullable BMCoreDataStoreCollectionDescriptor *)load:(NSString *)filePath;

- (nullable BMCoreDataStoreDescriptor *)storeDescriptorByName:(NSString *)storeName;
- (nullable NSManagedObjectModel *)managedObjectModel;

- (BOOL)save:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
