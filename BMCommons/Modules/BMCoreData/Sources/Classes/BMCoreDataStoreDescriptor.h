//
//  BMCoreDataStoreDescriptor.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/20/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreDataModelDescriptor.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMCoreDataStoreDescriptor : NSObject<NSCoding> 

@property (nullable, nonatomic, strong) NSString *storeName;
@property (nullable, nonatomic, strong) NSString *modelConfiguration;
@property (nullable, strong, nonatomic, readonly) NSURL *storeURL;
@property (nullable, nonatomic, strong) NSArray *modelDescriptors;

+ (BMCoreDataStoreDescriptor *)storeDescriptorWithName:(NSString *)storeName configuration:(nullable NSString *)theModelConfiguration modelDescriptors:(NSArray *)modelDescriptors;

/** 
 Convenience method to return a descriptor for the default case in which there is one model within a store.
 */
+ (BMCoreDataStoreDescriptor *)storeDescriptorWithModelName:(NSString *)modelName version:(NSInteger)version configuration:(nullable NSString *)configuration;

+ (NSInteger)existingVersionForModelName:(NSString *)modelName configuration:(nullable NSString *)configuration;

- (nullable NSManagedObjectModel *)managedObjectModel;

- (nullable NSString *)versionString;

@end

NS_ASSUME_NONNULL_END
