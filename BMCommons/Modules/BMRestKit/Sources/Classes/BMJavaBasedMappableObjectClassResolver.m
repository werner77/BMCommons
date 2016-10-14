//
//  BMMappableObjectTypeResolver.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/09/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMJavaBasedMappableObjectClassResolver.h>
#import <BMCommons/NSString+BMCommons.h>
#import <BMCommons/BMCore.h>

@implementation BMJavaBasedMappableObjectClassResolver

- (NSArray *)genericClassNamesFromString:(NSString *)classNameString {
    
    if (!classNameString) {
        return nil;
    }
    
    NSMutableArray *ret = [NSMutableArray array];
    
    NSMutableString *s = [NSMutableString stringWithString:classNameString];
    NSRange range1;
    NSRange range2;
    
    BOOL classFound;
    do {
        classFound = NO;
        NSString *className = nil;
        range1 = [s rangeOfString:@"<" options:NSBackwardsSearch];
        if (range1.location != NSNotFound) {
            range2 = [s rangeOfString:@">" options:0 range:NSMakeRange(range1.location, s.length - range1.location)];
            if (range2.location != NSNotFound && range2.location > range1.location) {
                className = [s substringWithRange:NSMakeRange(range1.location + 1, range2.location - range1.location - 1)];
                if (className.length > 0) {
                    [ret insertObject:className atIndex:0];
                    classFound = YES;
                    [s deleteCharactersInRange:NSMakeRange(range1.location, range2.location - range1.location + 1)];
                }
            }
        }
    } while (classFound);
    
    [ret insertObject:s atIndex:0];
    
    return ret;
}

- (BOOL)getObjectType:(NSString **)objectType namespace:(NSString **)namespace fromFQClassName:(NSString *)classNameString {
    
    classNameString = [classNameString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]{} \t\n"]];
    
    NSArray *classNameComponents = [classNameString componentsSeparatedByString:@","];
    if (classNameComponents.count > 1) {
        //Only parse the value type
        LogWarn(@"For dictionaries the key type is ignored and is always a string, key type found: %@", classNameComponents.firstObject);
    }
    classNameString = classNameComponents.lastObject;
    
    NSArray *genericClassNames = [self genericClassNamesFromString:classNameString];
    
    NSMutableString *className = [NSMutableString string];
    
    for (NSString *s in genericClassNames) {
        if (className.length > 0) {
            [className appendString:@"Of"];
        }
        
        NSRange range = [s rangeOfString:@"." options:NSBackwardsSearch];
        NSString *genericClassName = nil;
        if (range.location == NSNotFound || range.location >= s.length) {
            genericClassName = s;
        } else {
            genericClassName = [s substringFromIndex:(range.location + 1)];
        }
        [className appendString:genericClassName];
    }
    [className replaceOccurrencesOfString:@"$" withString:@"_" options:0 range:NSMakeRange(0, className.length)];
    
    BOOL parsedSuccessfully = NO;
    
    if (className.length > 0) {
        parsedSuccessfully = YES;
        
        NSRange range = [genericClassNames.firstObject rangeOfString:@"." options:NSBackwardsSearch];
        NSString *theNameSpace = nil;
        if (range.location != NSNotFound) {
            theNameSpace = [genericClassNames.firstObject substringToIndex:range.location];
        }
        if (objectType) {
            *objectType = className;
        }
        if (namespace) {
            *namespace = theNameSpace;
        }
    }
    return parsedSuccessfully;
}

- (BOOL)getObjectType:(NSString **)objectType namespace:(NSString **)namespace parentObjectType:(NSString **)parentObjectType parentNamespace:(NSString **)parentNamespace fromDescriptor:(NSString *)title {
    
    NSArray *components = [title componentsSeparatedByString:@":"];
    BOOL valid = components.count >= 1 && components.count <= 2;
    if (components.count >= 1) {
        valid = valid && [self getObjectType:objectType namespace:namespace fromFQClassName:[components objectAtIndex:0]];
    }
    if (components.count >= 2) {
        valid = valid && [self getObjectType:parentObjectType namespace:parentNamespace fromFQClassName:[components objectAtIndex:1]];
    }
    return valid;
}

@end
