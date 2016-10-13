//
//  BMCoreDataModelDescriptor.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/20/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface BMCoreDataModelDescriptor : NSObject<NSCoding> 

@property (strong, nonatomic, readonly) NSURL *modelURL;

@property (nonatomic, strong) NSString *modelName;
@property (nonatomic, assign) NSInteger modelVersion;

+ (NSURL *)modelURLForModelName:(NSString *)modelName version:(NSInteger)version;
+ (BMCoreDataModelDescriptor *)modelDescriptorWithModelName:(NSString *)modelName version:(NSInteger)version;

- (NSManagedObjectModel *)managedObjectModel;

@end
