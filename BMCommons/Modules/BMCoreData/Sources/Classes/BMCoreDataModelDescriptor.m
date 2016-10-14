//
//  BMCoreDataModelDescriptor.m
//  BMCommons
//
//  Created by Werner Altewischer on 10/20/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMCoreDataModelDescriptor.h>
#import <BMCommons/BMCore.h>

@implementation BMCoreDataModelDescriptor {
}

+ (NSURL *)modelURLForModelName:(NSString *)modelName version:(NSInteger)version {
	
	if (version < 0) return nil;
    
	NSString *modelVersionName = modelName;
	
	if (version > 0) {
		modelVersionName = [NSString stringWithFormat:@"%@%zd", modelName, version];
	}
	
	NSString *modelPath = [[NSBundle mainBundle] pathForResource:modelVersionName ofType:@"mom" inDirectory:[NSString stringWithFormat:@"%@%@", modelName, @".momd"]];  
	if (modelPath == nil) {
		//If not found in dir, then check the root
		modelPath = [[NSBundle mainBundle] pathForResource:modelVersionName ofType:@"mom"];  
	}
    
	if (modelPath == nil) {
		LogError(@"Could not load model with name %@.mom from resources", modelVersionName); 
		return nil;
	}
	
	return [NSURL fileURLWithPath:modelPath isDirectory:NO];
}

+ (BMCoreDataModelDescriptor *)modelDescriptorWithModelName:(NSString *)modelName version:(NSInteger)version {
    BMCoreDataModelDescriptor *descriptor = [[self alloc] init];
    descriptor.modelName = modelName;
    descriptor.modelVersion = version;
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
        self.modelVersion = (NSInteger)[coder decodeInt64ForKey:@"modelVersion"];
        self.modelName = [coder decodeObjectForKey:@"modelName"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt64:self.modelVersion forKey:@"modelVersion"];
    [coder encodeObject:self.modelName forKey:@"modelName"];
}

- (NSURL *)modelURL {
    return [[self class] modelURLForModelName:self.modelName version:self.modelVersion];
}

- (NSManagedObjectModel *)managedObjectModel {
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
}


@end
