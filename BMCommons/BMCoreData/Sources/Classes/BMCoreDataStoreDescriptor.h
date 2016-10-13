//
//  BMCoreDataStoreDescriptor.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/20/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreDataModelDescriptor.h>

@interface BMCoreDataStoreDescriptor : NSObject<NSCoding> 

@property (nonatomic, strong) NSString *storeName;
@property (nonatomic, strong) NSString *modelConfiguration;
@property (strong, nonatomic, readonly) NSURL *storeURL;
@property (nonatomic, strong) NSArray *modelDescriptors;

+ (BMCoreDataStoreDescriptor *)storeDescriptorWithName:(NSString *)storeName configuration:(NSString *)theModelConfiguration modelDescriptors:(NSArray *)modelDescriptors;

/** 
 Convenience method to return a descriptor for the default case in which there is one model within a store.
 */
+ (BMCoreDataStoreDescriptor *)storeDescriptorWithModelName:(NSString *)modelName version:(NSInteger)version configuration:(NSString *)configuration;

+ (NSInteger)existingVersionForModelName:(NSString *)modelName configuration:(NSString *)configuration;

- (NSManagedObjectModel *)managedObjectModel;

- (NSString *)versionString;

@end
