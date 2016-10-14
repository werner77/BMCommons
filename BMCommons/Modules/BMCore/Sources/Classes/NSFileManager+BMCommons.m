//
//  NSFileManager+BMCommons.m
//  BMCommons
//
//  Created by Werner Altewischer on 15/08/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "NSFileManager+BMCommons.h"
#import "NSDictionary+BMCommons.h"

static NSString * const XAFinderInfo = @XATTR_FINDERINFO_NAME;
static NSString * const XAFinderComment = @"com.apple.metadata:kMDItemFinderComment";
static NSString * const XAResourceFork = @XATTR_RESOURCEFORK_NAME;

@implementation NSFileManager (BMCommons)


#pragma mark - Private helper methods

- (void)setError:(NSError **)error withFunctionName:(NSString *)functionName name:(NSString *)name path:(NSString *)path follow:(NSNumber *)follow {
    [self setError:error withFunctionName:functionName name:name path:path follow:follow mode:nil];
}

- (void)setError:(NSError **)error withFunctionName:(NSString *)functionName name:(NSString *)name path:(NSString *)path follow:(NSNumber *)follow mode:(NSNumber *)mode {
    if (error) {
        NSMutableDictionary *userInfo = [NSMutableDictionary new];

        [userInfo bmSafeSetObject:[NSString stringWithUTF8String:strerror(errno)] forKey:@"error"];

        [userInfo bmSafeSetObject:functionName forKey:@"function"];

        [userInfo bmSafeSetObject:name forKey:@":name"];
        [userInfo bmSafeSetObject:path forKey:@":path"];
        [userInfo bmSafeSetObject:follow forKey:@":traverseLink"];
        [userInfo bmSafeSetObject:mode forKey:@":mode"];
        
        *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:userInfo];
    }
}

#pragma mark - Category methods

- (BOOL)bmClearContentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
    NSDirectoryEnumerator* en = [self enumeratorAtPath:path];
    BOOL ret = YES;
    NSString* file;
    while (file = [en nextObject]) {
        NSError* err = nil;
        ret = [self removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err] && ret;
        if (err != nil && error != nil) {
            *error = err;
        }
    }
    return ret;
}

- (NSArray*)bmExtendedAttributeNamesAtPath:(NSString *)path traverseLink:(BOOL)follow error:(NSError**)err {
    int flags = follow? 0 : XATTR_NOFOLLOW;
    
    // get size of name list
    const char *cPath = [path fileSystemRepresentation];
    ssize_t nameBuffLen = listxattr(cPath, NULL, 0, flags);
    if (nameBuffLen == -1) {
        [self setError:err withFunctionName:@"listxattr" name:nil path:path follow:@(follow)];
        return nil;
    } else if (nameBuffLen == 0) {
        return [NSArray array];
    } else {
        // get name list
        NSMutableData *nameBuff = [NSMutableData dataWithLength:nameBuffLen];
        listxattr(cPath, [nameBuff mutableBytes], nameBuffLen, flags);
        
        // convert to array
        NSMutableArray * names = [NSMutableArray arrayWithCapacity:5];
        char *nextName, *endOfNames = [nameBuff mutableBytes] + nameBuffLen;
        for(nextName = [nameBuff mutableBytes]; nextName < endOfNames; nextName += 1+strlen(nextName))
            [names addObject:[NSString stringWithUTF8String:nextName]];
        return names;
    }
}

- (NSData*)bmExtendedAttribute:(NSString *)name atPath:(NSString *)path traverseLink:(BOOL)follow error:(NSError**)err {
    int flags = follow? 0 : XATTR_NOFOLLOW;
    // get length
    const char *cPath = [path fileSystemRepresentation];
    const char *cName = [name UTF8String];
    
    ssize_t attrLen = getxattr(cPath, cName, NULL, 0, 0, flags);
    if (attrLen == -1) {
        [self setError:err withFunctionName:@"getxattr" name:name path:path follow:@(follow)];
        return nil;
    } else {
        // get attribute data
        NSMutableData * attrData = [NSMutableData dataWithLength:attrLen];
        getxattr(cPath, cName, [attrData mutableBytes], attrLen, 0, flags);
        return attrData;
    }
}

- (NSDictionary*)bmExtendedAttributesAtPath:(NSString *)path traverseLink:(BOOL)follow error:(NSError**)err {
    // get names
    NSArray * names = [self bmExtendedAttributeNamesAtPath:path traverseLink:follow error:err];
    if (names == nil) {
        return nil;
    } else {
        NSMutableDictionary * attrs = [NSMutableDictionary dictionaryWithCapacity:[names count]];
        // get attributes
        for(NSString * name in names) {
            if (![name isEqualToString:XAResourceFork]) {
                NSData * attr = [self bmExtendedAttribute:name atPath:path traverseLink:follow error:err];
                if (attr == nil) return nil;
                [attrs setObject:attr forKey:name];
            }
        }
        return attrs;
    }
}

- (BOOL)bmSetExtendedAttribute:(NSString *)name value:(NSData *)value atPath:(NSString *)path traverseLink:(BOOL)follow mode:(BMXAMode)mode error:(NSError**)err {
    int flags = (follow? 0 : XATTR_NOFOLLOW) | mode;
    if (0 == setxattr([path fileSystemRepresentation], [name UTF8String], [value bytes], [value length], 0, flags)) {
        return YES;
    } else {
        [self setError:err withFunctionName:@"setxattr" name:name path:path follow:@(follow) mode:@(mode)];
        return NO;
    }
}

- (BOOL)bmRemoveExtendedAttribute:(NSString *)name atPath:(NSString *)path traverseLink:(BOOL)follow error:(NSError**)err {
    int flags = (follow? 0 : XATTR_NOFOLLOW);
    if (0 == removexattr([path fileSystemRepresentation], [name UTF8String], flags)) {
        return YES;
    } else {
        [self setError:err withFunctionName:@"removexattr" name:name path:path follow:@(follow)];
        return NO;
    }
}

- (BOOL)bmSetExtendedAttributes:(NSDictionary *)attrs atPath:(NSString *)path traverseLink:(BOOL)follow overwrite:(BOOL)overwrite error:(NSError**)err {
    NSArray * oldNames = [self bmExtendedAttributeNamesAtPath:path traverseLink:follow error:err];
    if (oldNames == nil) {
        return NO;
    } else {
        NSArray * newNames = [attrs allKeys];
        BOOL success = YES;
        
        // remove attributes
        if (overwrite) {
            NSMutableSet * attrsToRemove = [NSMutableSet setWithArray:oldNames];
            [attrsToRemove minusSet:[NSSet setWithArray:newNames]];
            [attrsToRemove removeObject:XAResourceFork];
            for(NSString * name in attrsToRemove) {
                if (![self bmRemoveExtendedAttribute:name atPath:path traverseLink:follow error:err]) {
                    success = NO;
                    break;
                }
            }
        }
        
        if (success) {
            // set attributes
            for (NSString * name in newNames) {
                if (![self bmSetExtendedAttribute:name value:[attrs objectForKey:name] atPath:path traverseLink:follow mode:0 error:err]) {
                    success = NO;
                    break;
                }
            }
        }
        return success;
    }
}

@end
