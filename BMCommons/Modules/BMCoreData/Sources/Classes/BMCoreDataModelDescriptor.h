//
//  BMCoreDataModelDescriptor.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/20/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMCoreDataModelDescriptor : NSObject<NSCoding> 

@property (nullable, strong, nonatomic, readonly) NSURL *modelURL;

@property (nullable, nonatomic, strong) NSString *modelName;
@property (nonatomic, assign) NSInteger modelVersion;

+ (nullable NSURL *)modelURLForModelName:(NSString *)modelName version:(NSInteger)version;
+ (BMCoreDataModelDescriptor *)modelDescriptorWithModelName:(NSString *)modelName version:(NSInteger)version;

- (nullable NSManagedObjectModel *)managedObjectModel;

@end

NS_ASSUME_NONNULL_END
