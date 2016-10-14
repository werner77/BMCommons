//
//  BMAbstractMappableObjectClassResolver.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/09/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMMappableObjectClassResolver.h>

@interface BMAbstractMappableObjectClassResolver : NSObject<BMMappableObjectClassResolver>

@property (nonatomic, strong) NSString *classNamePrefix;
@property (nonatomic, strong) NSString *classNameSuffix;
@property (nonatomic, strong) NSDictionary *namespacePrefixMappings;

@end

@interface BMAbstractMappableObjectClassResolver(Protected)

//To be implemented by sub classes
- (BOOL)getObjectType:(NSString **)objectType namespace:(NSString **)namespaceString parentObjectType:(NSString **)parentObjectType parentNamespace:(NSString **)parentNamespace fromDescriptor:(NSString *)descriptor;

@end
