/**
 *  BMCore.m
 *  BMCommons
 *
 *  Created by Werner Altewischer on 1/26/11.
 *  Copyright 2011 BehindMedia. All rights reserved.
 */

#import <BMCommons/BMCore.h>
#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

static const void* BMRetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
static void BMReleaseNoOp(CFAllocatorRef allocator, const void *value) { }

NSUInteger BMAnyEnumValueMask = ((NSUInteger)-1);

NSMutableArray* BMCreateNonRetainingArray() {
  CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
  callbacks.retain = BMRetainNoOp;
  callbacks.release = BMReleaseNoOp;
  return (NSMutableArray*)CFBridgingRelease(CFArrayCreateMutable(nil, 0, &callbacks));
}

NSMutableDictionary* BMCreateNonRetainingDictionary() {
  CFDictionaryKeyCallBacks keyCallbacks = kCFTypeDictionaryKeyCallBacks;
  CFDictionaryValueCallBacks callbacks = kCFTypeDictionaryValueCallBacks;
  callbacks.retain = BMRetainNoOp;
  callbacks.release = BMReleaseNoOp;
  return (NSMutableDictionary*)CFBridgingRelease(CFDictionaryCreateMutable(nil, 0, &keyCallbacks, &callbacks));
}

BOOL BMIsEmptyArray(id object) {
  return [object isKindOfClass:[NSArray class]] && ![(NSArray*)object count];
}

BOOL BMIsEmptySet(id object) {
  return [object isKindOfClass:[NSSet class]] && ![(NSSet*)object count];
}

BOOL BMIsEmptyString(id object) {
  return [object isKindOfClass:[NSString class]] && ![(NSString*)object length];
}

CGRect BMRectContract(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - dx, rect.size.height - dy);
}

CGRect BMRectShift(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectOffset(BMRectContract(rect, dx, dy), dx, dy);
}

NSLocale* BMCurrentLocale() {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
  if (languages.count > 0) {
    NSString *currentLanguage = [languages objectAtIndex:0];
    return [[NSLocale alloc] initWithLocaleIdentifier:currentLanguage];
  } else {
    return [NSLocale currentLocale];
  }
}

BOOL BMIsBundleURL(NSString* URL) {
  if (URL.length >= 9) {
    return [URL rangeOfString:@"bundle://" options:0 range:NSMakeRange(0,9)].location == 0;
  } else {
    return NO;
  }
}

BOOL BMIsDocumentsURL(NSString* URL) {
  if (URL.length >= 12) {
    return [URL rangeOfString:@"documents://" options:0 range:NSMakeRange(0,12)].location == 0;
  } else {
    return NO;
  }
}

#if TARGET_OS_IPHONE

NSString *BMOSVersion() {
    return [[UIDevice currentDevice] systemVersion];
}

BOOL BMOSVersionIsAtLeast(NSString *version) {

    static NSCharacterSet *kSeparator = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        kSeparator = [NSCharacterSet characterSetWithCharactersInString:@".,;: \t\n\r-_()[]{}|\\/?~`!@#$%^&*+=<>"];
    });

    NSComparisonResult comparisonResult = NSOrderedSame;

    NSArray *systemVersionComponents = [BMOSVersion() componentsSeparatedByCharactersInSet:kSeparator];
    NSArray *versionComponents = [version componentsSeparatedByCharactersInSet:kSeparator];

    for (NSUInteger i = 0; i < MAX(systemVersionComponents.count, versionComponents.count); ++i) {
        NSString *systemVersionComponent = [systemVersionComponents bmSafeObjectAtIndex:i];
        NSString *versionComponent = [versionComponents bmSafeObjectAtIndex:i];

        NSInteger sv = [systemVersionComponent integerValue];
        NSInteger v = [versionComponent integerValue];

        if (systemVersionComponent == nil || versionComponent == nil) {
            if (sv > 0) {
                comparisonResult = NSOrderedAscending;
            } else if (v > 0) {
                comparisonResult = NSOrderedDescending;
            }
            break;
        } else {
            if (comparisonResult == NSOrderedSame) {
                if (v > sv) {
                    comparisonResult = NSOrderedDescending;
                    break;
                } else if (v < sv) {
                    comparisonResult = NSOrderedAscending;
                    break;
                }
            }
        }
    }
    return comparisonResult != NSOrderedDescending;
}

#endif

NSString* BMPathForBundleResource(NSString* relativePath) {
  NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
  return [resourcePath stringByAppendingPathComponent:relativePath];
}

NSString* BMPathForDocumentsResource(NSString* relativePath) {
  static NSString* documentsPath = nil;
  if (!documentsPath) {
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsPath = [dirs objectAtIndex:0];
  }
  return [documentsPath stringByAppendingPathComponent:relativePath];
}

IMP BMReplaceMethodImplementation(Class cls, SEL methodSelector, IMP newImplementation) {
    IMP ret = NULL;
    Method method = class_getInstanceMethod(cls, methodSelector);
    if (method) {
        ret = method_setImplementation(method, newImplementation);
    }
    return ret;
}

IMP BMReplaceClassMethodImplementation(Class cls, SEL methodSelector, IMP newImplementation) {
    IMP ret = NULL;
    Method method = class_getClassMethod(cls, methodSelector);
    if (method) {
        ret = method_setImplementation(method, newImplementation);
    }
    return ret;
}

inline int32_t BMShortenUIntToIntSafely(uint64_t longInt, NSString *exceptionReason) {
    uint32_t shortInt = BMShortenUIntSafely(longInt, exceptionReason);
    int32_t ret = (int32_t)shortInt;
    if (ret < 0) {
        if (exceptionReason == nil) {
            exceptionReason = @"Supplied unsigned 32 bit exceeds the max signed 32 bit value so cannot be cast safely";
        }
        @throw [NSException exceptionWithName:@"BMOverflowException" reason:exceptionReason userInfo:nil];
    }
    return ret;
}

inline uint32_t BMShortenUIntSafely(uint64_t longInt, NSString *exceptionReason) {
    uint32_t ret = (uint32_t)longInt;
    if (longInt != (uint64_t)ret) {
        if (exceptionReason == nil) {
            exceptionReason = @"Supplied unsigned 64 bit exceeds the max unsigned 32 bit value so cannot be cast safely";
        }
        @throw [NSException exceptionWithName:@"BMOverflowException" reason:exceptionReason userInfo:nil];
    }
    return ret;
}

inline int32_t BMShortenIntSafely(int64_t longInt, NSString *exceptionReason) {
    int32_t ret = (int32_t)longInt;
    if (longInt != (int64_t)ret) {
        if (exceptionReason == nil) {
            exceptionReason = @"Supplied signed 64 bit exceeds the max or min signed 32 bit value so cannot be cast safely";
        }
        @throw [NSException exceptionWithName:@"BMOverflowException" reason:exceptionReason userInfo:nil];
    }
    return ret;
}

void BMThrowException(NSString *exceptionName, NSString *reason) {
    @throw [NSException exceptionWithName:exceptionName reason:reason userInfo:nil];
}

void BMThrowIllegalArgumentException(NSString *reason) {
    BMThrowException(@"BMIllegalArgumentException", reason);
}

@implementation BMCore

static BMCore *instance = nil;

+ (id)instance {
    if (instance == nil) {
        instance = [BMCore new];
    }
    return instance;
}

@end
