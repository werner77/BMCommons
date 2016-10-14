//
//  NSDictionary+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 18/07/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "NSDictionary+BMCommons.h"
#import <BMCommons/BMPropertyDescriptor.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMObjectHelper.h>
#import <BMCommons/NSObject+BMCommons.h>

@implementation NSDictionary(BMCommons)

#pragma mark - Private

+ (NSCharacterSet *)delimiterCharacterSet {
    static dispatch_once_t onceToken;
    static NSCharacterSet *delimiterCharacterSet = nil;
    dispatch_once(&onceToken, ^{
        delimiterCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"/[]"];
    });
    return delimiterCharacterSet;
}

- (NSObject *)valueForXPathComponents:(NSMutableArray *)xpathComponents node:(id)currentNode {
    
    if (currentNode == nil) {
        return nil;
    }
    
    NSString *currentKey = xpathComponents.count > 0 ? [xpathComponents objectAtIndex:0] : nil;
    id nextNode = nil;
    
    if (currentKey == nil) {
        //We reached the end: return the current node
        return currentNode;
    } else {
        if ([currentNode isKindOfClass:[NSArray class]]) {
            // current key must be a number
            NSArray * currentArray = (NSArray *) currentNode;
            NSInteger index = [currentKey integerValue];
            if (index < currentArray.count) {
                nextNode = [currentArray objectAtIndex:index];
            }
        } else if ([currentNode isKindOfClass:[NSObject class]]) {
            @try {
                nextNode = [currentNode valueForKey:currentKey];
            } @catch (NSException *exception) {
                //ignore: key is undefined
            }
        }
    }
    
    //Count > 0 so we can remove the first
    [xpathComponents removeObjectAtIndex:0];
    return [self valueForXPathComponents:xpathComponents node:nextNode];
}

#pragma mark - Public

- (id)bmObjectForKey:(id)aKey ofClass:(Class)c {
    id o = [self objectForKey:aKey];
    return [o bmCastSafely:c];
}

- (id)bmValueForXPath:(NSString *)xpath {
    
    NSMutableArray *xpathComponents = [NSMutableArray arrayWithArray:[xpath componentsSeparatedByCharactersInSet:[[self class] delimiterCharacterSet]]];
    
    //Filter out empty components
    for (NSUInteger i = 0; i < xpathComponents.count; ++i) {
        NSString *component = [xpathComponents objectAtIndex:i];
        if ([BMStringHelper isEmpty:component]) {
            [xpathComponents removeObjectAtIndex:i--];
        }
    }
    
    return [BMObjectHelper filterNSNullObject:[self valueForXPathComponents:xpathComponents node:self]];
}

- (id)bmRequiredValueForXPath:(NSString *)xpath withClass:(Class)c {
    return [self bmCheckNotNil:[self bmValueForXPath:xpath withClass:c] path:xpath];
}

- (id)bmRequiredValueForXPath:(NSString *)xpath withValueTransformer:(NSValueTransformer *)valueTransformer {
    return [self bmCheckNotNil:[self bmValueForXPath:xpath withValueTransformer:valueTransformer] path:xpath];
}

- (id)bmValueForXPath:(NSString *)xpath withClass:(Class)c defaultValue:(id)defaultValue {
    return [self bmFilterValue:[self bmValueForXPath:xpath withClass:c] withDefaultValue:defaultValue];
}

- (id)bmValueForXPath:(NSString *)xpath withValueTransformer:(NSValueTransformer *)valueTransformer defaultValue:(id)defaultValue {
    return [self bmFilterValue:[self bmValueForXPath:xpath withValueTransformer:valueTransformer] withDefaultValue:defaultValue];
}

- (id)bmValueForXPath:(NSString *)xpath withClass:(Class)c {
    id value = [self bmValueForXPath:xpath];
    value = [value bmCastSafely:c];
    return value;
}

- (id)bmValueForXPath:(NSString *)xpath withValueTransformer:(NSValueTransformer *)valueTransformer {
    id value = [self bmValueForXPath:xpath];
    if (value && valueTransformer && ![value isKindOfClass:[[valueTransformer class] transformedValueClass]]) {
        @try {
            value = [valueTransformer transformedValue:value];
        } @catch (NSException *exception) {
            //Ignore: could not transform value
            if ([NSObject isBMThrowAssertionExceptions]) {
                @throw exception;
            } else {
                value = nil;
            }
        }
        value = [value bmCastSafely:[[valueTransformer class] transformedValueClass]];
    }
    return value;
}

+ (instancetype)bmDictionaryFromArray:(NSArray *)array withKeyPropertyDescriptor:(BMPropertyDescriptor *)pd {
    return [self bmDictionaryFromArray:array withKeySelectorBlock:^id <NSCopying>(id object) {
        return [pd callGetterOnTarget:object ignoreFailure:YES];
    }];
}

+ (instancetype)bmDictionaryFromArray:(NSArray *)array withKeySelectorBlock:(id<NSCopying>(^)(id object))keySelectorBlock {
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:array.count];
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (id object in array) {
        if (object != nil && keySelectorBlock != nil) {
            id key = keySelectorBlock(object);
            if (key != nil) {
                [keys addObject:key];
                [objects addObject:object];
            }
        }
    }
    return [[self alloc] initWithObjects:objects forKeys:keys];
}

- (id)bmCheckNotNil:(id)value path:(NSString *)path {
    if ([NSObject isBMThrowAssertionExceptions] && value == nil) {
        NSException *ex = [NSException exceptionWithName:@"BMRequiredValueException" reason:[NSString stringWithFormat:@"Value for path '%@' should not be nil", path] userInfo:nil];
        @throw ex;
    }
    return value;
}

- (id)bmFilterValue:(id)value withDefaultValue:(id)defaultValue {
    if (value == nil) {
        value = defaultValue;
    }
    return value;
}

@end

@implementation NSMutableDictionary(BMCommons)

- (void)bmSafeSetObject:(id)object forKey:(id)key {
    if (object && key) {
        [self setObject:object forKey:key];
    }
}

- (id)bmObjectForKey:(id)key withDefaultConstructor:(id (^)(void))constructor {
    id ret = [self objectForKey:key];
    if (ret == nil && constructor != nil) {
        ret = constructor();
        if (ret) {
            [self setObject:ret forKey:key];
        }
    }
    return ret;
}

@end
