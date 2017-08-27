//
//  BMAbstractMappableObjectClassResolver.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/09/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMMappableObjectClassResolver.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMAbstractMappableObjectClassResolver : NSObject<BMMappableObjectClassResolver>

@property (nullable, nonatomic, strong) NSString *classNamePrefix;
@property (nullable, nonatomic, strong) NSString *classNameSuffix;
@property (nullable, nonatomic, strong) NSDictionary *namespacePrefixMappings;

//Module support
@property (nonatomic, assign) BOOL swiftMode;
@property (nullable, nonatomic, strong) NSString *defaultModule;

@end

@interface BMAbstractMappableObjectClassResolver(Protected)

//To be implemented by sub classes
- (BOOL)getObjectType:(NSString * _Nonnull *_Nonnull )objectType namespace:(NSString * _Nullable *_Nonnull )namespaceString parentObjectType:(NSString * _Nullable *_Nonnull )parentObjectType parentNamespace:(NSString * _Nullable *_Nonnull )parentNamespace fromDescriptor:(NSString *)descriptor;

@end

NS_ASSUME_NONNULL_END
