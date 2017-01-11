//
//  BMAbstractMappableObjectClassResolver.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/09/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAbstractMappableObjectClassResolver.h>
#import <BMCommons/NSString+BMCommons.h>

@implementation BMAbstractMappableObjectClassResolver

- (BOOL)getMappableObjectClassName:(NSString **)mappableObjectClassName andParentClassName:(NSString **)parentClassName fromDescriptor:(NSString *)descriptor {
    
    NSString *objectType = nil;
    NSString *parentObjectType = nil;
    NSString *namespace = nil;
    NSString *parentNamespace = nil;
    
    BOOL ret = [self getObjectType:&objectType namespace:&namespace parentObjectType:&parentObjectType parentNamespace:&parentNamespace fromDescriptor:descriptor];
    if (ret) {
        if (mappableObjectClassName) {
            *mappableObjectClassName = [self mappableObjectClassNameForObjectType:objectType namespace:namespace];
        }
        if (parentClassName) {
            *parentClassName = [self mappableObjectClassNameForObjectType:parentObjectType namespace:parentNamespace];
        }
    }
    return ret;
}

- (NSString *)mappableObjectClassNameForObjectType:(NSString *)theName namespace:(NSString *)theNamespace {
    
    if (!theName) {
        return nil;
    }
    
    theName = [theName bmStringWithUppercaseFirstChar];
    NSString *moduleName = self.defaultModule;
    
    if (theNamespace) {
        id o = [self.namespacePrefixMappings objectForKey:theNamespace];
        
        NSString *prefix = nil;

        if ([o isKindOfClass:[NSDictionary class]]) {
            prefix = [o objectForKey:@"prefix"];
            NSString *m = [o objectForKey:@"module"];
            if (m != nil) {
                moduleName = m;
            }
        } else if ([o isKindOfClass:[NSString class]]) {
            prefix = o;
        }

        if (prefix) {
            theName = [prefix stringByAppendingString:theName];
        }
    }
    
    if (self.classNamePrefix) {
        theName = [self.classNamePrefix stringByAppendingString:theName];
    }
    
    if (self.classNameSuffix && ![theName hasSuffix:self.classNameSuffix]) {
        theName = [theName stringByAppendingString:self.classNameSuffix];
    }
    
    if (moduleName.length > 0 && self.swiftMode) {
        theName = [NSString stringWithFormat:@"%@.%@", moduleName, theName];
    }
    
    return theName;
}

- (BMMAppableObjectNameSpaceType)typeForNamespace:(NSString *)theNamespace {
    BMMAppableObjectNameSpaceType namespaceType = BMMAppableObjectNameSpaceTypeDefault;
    NSNumber *qualifiedOverride = [self qualifiedOverrideForNamespace:theNamespace];
    
    if (qualifiedOverride) {
        if (qualifiedOverride.boolValue) {
            namespaceType = BMMAppableObjectNameSpaceTypeQualified;
        } else {
            namespaceType = BMMAppableObjectNameSpaceTypeUnqualified;
        }
    }
    return namespaceType;
}

#pragma mark - Private

- (NSNumber *)qualifiedOverrideForNamespace:(NSString *)namespace {
    NSNumber *n = nil;
    
    id o = [self.namespacePrefixMappings objectForKey:namespace];
    
    if ([o isKindOfClass:[NSDictionary class]]) {
        n = [o objectForKey:@"qualified"];
    }
    
    return n;
}

@end

@implementation BMAbstractMappableObjectClassResolver(Protected)

//To be implemented by sub classes
- (BOOL)getObjectType:(NSString **)objectType namespace:(NSString **)namespaceString parentObjectType:(NSString **)parentObjectType parentNamespace:(NSString **)parentNamespace fromDescriptor:(NSString *)descriptor {
    return NO;
}

@end
