/**
 *  BMCore.h
 *  BMCommons
 *
 *  Created by Werner Altewischer on 1/26/11.
 *  Copyright 2011 BehindMedia. All rights reserved.
 */

#import <BMCommons/BMVersionAvailability.h>

//Should be imported first, because it redefines NSLocalizedString
#import <BMCommons/BMCoreObject.h>
#import <BMCommons/BMLocalization.h>
#import "BMNullableArray.h"

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#	import <UIKit/UIKit.h>
#else
#	import <AppKit/AppKit.h>
#endif

#import <CoreData/CoreData.h>
#import <BMCommons/BMLogging.h>

#import <BMCommons/BMURLCache.h>
#import <BMCommons/BMSingleton.h>
#import <BMCommons/NSArray+BMCommons.h>
#import <objc/runtime.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
// Cache

#define BM_DEFAULT_CACHE_INVALIDATION_AGE (60.0*60.0*24.0) // 1 day
#define BM_CACHE_EXPIRATION_AGE_NEVER (1.0 / 0.0)    // inf

#define BMIMAGE(_URL) [[BMURLCache sharedCache] imageForURL:_URL]


///////////////////////////////////////////////////////////////////////////////////////////////////
// Time

#define BM_MINUTE 60.0
#define BM_HOUR (60.0*BM_MINUTE)
#define BM_DAY (24.0*BM_HOUR)
#define BM_WEEK (7.0*BM_DAY)
#define BM_MONTH (30.0*BM_DAY)
#define BM_YEAR (365.0*BM_DAY)

///////////////////////////////////////////////////////////////////////////////////////////////////

#if __has_feature(objc_arc)
#define BM_RELEASE_SAFELY(__POINTER) { __POINTER = nil; }
#define BM_AUTORELEASE_SAFELY(__POINTER) { __POINTER = nil; }
#else
#define BM_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define BM_AUTORELEASE_SAFELY(__POINTER) { [__POINTER autorelease]; __POINTER = nil; }
#endif
#define BM_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }
#define BM_RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }


#define BM_LISTENER_METHODS_DECLARATION(protocol) \
@property(nonatomic, readonly) NSArray *listeners; \
- (void)addListener:(NSObject<protocol> *)listener; \
- (void)removeListener:(NSObject<protocol> *)listener; \
- (void)notifyListeners:(void (^)(NSObject<protocol> *listener))notifyBlock;

#define BM_LISTENER_METHODS_IMPLEMENTATION(protocol) \
- (BMNullableArray *)__listeners { \
    @synchronized (self) {\
        static const char *key = "com.behindmedia.bmcommons.core.listeners";\
        BMNullableArray *listeners = objc_getAssociatedObject(self, key);\
        if (listeners == nil) {\
            listeners = [BMNullableArray weakReferenceArray];\
            objc_setAssociatedObject(self, key, listeners, OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
        }\
        return listeners;\
    }\
}\
- (NSArray *)listeners {\
    BMNullableArray *listeners = self.__listeners;\
    @synchronized (listeners) {\
        BOOL nilListenerFound = NO; \
        NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:listeners.count];\
        for (id listener in listeners) {\
            if (listener == nil) {\
                BMAssertionFailure([NSString stringWithFormat:@"Listener of %@ was not properly cleaned up. Check for balanced addListener/removeListener calls!", self]); \
                nilListenerFound = YES; \
            } else {\
                [ret addObject:listener];\
            }\
        }\
        if (nilListenerFound) [listeners compact];\
        return ret;\
    }\
}\
- (void)addListener:(NSObject <protocol>*)listener {\
    if (listener != nil) { \
        BMNullableArray *listeners = self.__listeners;\
        @synchronized (listeners) {\
            if (![listeners containsObjectIdenticalTo:listener]) {\
                [listeners addObject:listener];\
            }\
        }\
    } \
}\
- (void)removeListener:(NSObject <protocol>*)listener {\
    if (listener != nil) { \
        BMNullableArray *listeners = self.__listeners;\
        @synchronized (listeners) {\
            [listeners removeObjectIdenticalTo:listener];\
        }\
    } \
}\
- (void)notifyListeners:(void (^)(NSObject<protocol> *listener))notifyBlock {\
    for (id listener in self.listeners) {\
        notifyBlock(listener);\
    }\
}

#define BM_PERFORM_IF_RESPONDS(x) { @try { (x); } @catch (NSException *e) { if (![e.name isEqual:NSInvalidArgumentException]) @throw e; }}

#define BM_SET_BIT(x, y) { x |= y; }
#define BM_UNSET_BIT(x, y) { x &= ~y; }
#define BM_CONTAINS_BIT(x, y) ((x & y) == y)
#define BM_NOT_CONTAINS_BIT(x, y) ((x & y) != y)

#define BM_APPEND_HASH_UNORDERED(hashCode, valueHash) {hashCode += valueHash;}
#define BM_APPEND_HASH_ORDERED(hashCode, valueHash) {hashCode = 37 * hashCode + valueHash;}
#define BM_EQUAL_IVAR(this,other,ivar) (this->ivar == other->ivar || [this->ivar isEqual:other->ivar])
#define BM_DISPATCH_ONCE(dispatchBlock) ({static dispatch_once_t token; dispatch_once(&token, dispatchBlock);})

#define BM_PARSE_VARARGS(firstArg) ({NSMutableArray *argArray = [NSMutableArray array]; \
va_list args; \
va_start(args, firstArg); \
if (firstObject != nil) [argArray addObject:firstArg]; \
id value; \
while ((value = va_arg(args, id)) != nil) {[argArray addObject:value]; } \
va_end(args); argArray;})

/**
 * NSUInteger with all bits set
 */
extern const NSUInteger BMAnyEnumValueMask;


#if defined(__cplusplus)
extern "C" {
#endif
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
     * Creates a mutable array which does not retain references to the objects it contains.
     */
    NSMutableArray* BMCreateNonRetainingArray();
    
    /**
     * Creates a mutable dictionary which does not retain references to the values it contains.
     */
    NSMutableDictionary* BMCreateNonRetainingDictionary();
    
    /**
     * Tests if an object is an array which is empty.
     */
    BOOL BMIsEmptyArray(id object);
    
    /**
     * Tests if an object is a set which is empty.
     */
    BOOL BMIsEmptyArray(id object);
    
    /**
     * Tests if an object is a string which is empty.
     */
    BOOL BMIsEmptyString(id object);
    
    /**
     * Returns a rectangle that is smaller or larger than the source rectangle.
     */
    CGRect BMRectContract(CGRect rect, CGFloat dx, CGFloat dy);
    
    /**
     * Returns a rectangle whose edges have been moved a distance and shortened by that distance.
     */
    CGRect BMRectShift(CGRect rect, CGFloat dx, CGFloat dy);
    
    /**
     * Gets the current system locale chosen by the user.
     *
     * This is necessary because [NSLocale currentLocale] always returns en_US.
     */
    NSLocale* BMCurrentLocale();
    
    /**
     Tests whether the specified URL has the bundle:// protocol prefix, specifying a file within the main bundle.
     
     Such a URL may be supplied to BMURLCache to load data from a bundle.
     */
    BOOL BMIsBundleURL(NSString* URL);
    
    /**
     Tests whether the specified ULR has the documents:// protocol prefix, specifying a file in the documents directory.
     
     Such a URL may be supplied to BMURLCache to load data from the documents directory.
     */
    BOOL BMIsDocumentsURL(NSString* URL);
    
    /**
     Converts a path within the main bundle to an absolute path.
     */
    NSString* BMPathForBundleResource(NSString* relativePath);
    
    /**
     Converts a path relative to the documents directory to an absolute path.
     */
    NSString* BMPathForDocumentsResource(NSString* relativePath);
    
    /**
     * Replaces an instance method implementation with a new one.
     *
     * The old method implementation is returned upon success.
     */
    IMP BMReplaceMethodImplementation(Class cls, SEL methodSelector, IMP newImplementation);

    /**
     * Replaces a class method implementation with a new one.
     *
     * The old method implementation is returned upon success.
     */
    IMP BMReplaceClassMethodImplementation(Class cls, SEL methodSelector, IMP newImplementation);

    /**
     Shortens a 64 bit unsigned int to a 32 bit int, throwing an exception if an overflow occurs.
     */
    uint32_t BMShortenUIntSafely(uint64_t longInt, NSString *exceptionReason);
    
    /**
     Shortens a 64 bit int to a 32 bit int, throwing an exception if an overflow occurs.
     */
    int32_t BMShortenIntSafely(int64_t longInt, NSString *exceptionReason);
    
    /**
     Converts an unsigned int to a signed int, throwing an exception if the result overflows the max value for a signed int.
     */
    int32_t BMShortenUIntToIntSafely(uint64_t longInt, NSString *exceptionReason);

    /**
     * Throws an exception of the specified type, with the specified reason.
     */
    void BMThrowException(NSString *exceptionName, NSString *reason);

    /**
     * Throws a BMIllegalArgumentException with the specified reason.
     */
    void BMThrowIllegalArgumentException(NSString *reason);

    /**
     * If fatalAssertionsEnabled this will throw an exception, else this will log a warning.
     */
    void BMAssertionFailure(NSString *message);

     /**
     Whether fatal assertions are enabled. Defaults to true for debug builds, false otherwise.
     */
     void BMSetFatalAssertionsEnabled(BOOL enabled);


#if TARGET_OS_IPHONE
    /**
    * Gets the current runtime version of iPhone OS.
    */
    NSString *BMOSVersion(void);

    /**
     * Checks if the link-time version of the OS is at least a certain version.
     */
    BOOL BMOSVersionIsAtLeast(NSString *version);

#endif


#if defined(__cplusplus)
}
#endif

/**
 BMCore Module
 */
@interface BMCore : NSObject

+ (id)instance;

@end
