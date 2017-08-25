//
//  NSFileManager+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 15/08/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/xattr.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BMXAMode) {
    BMXAAnyMode = 0,
    BMXACreate = XATTR_CREATE,   /* set the value, fail if attr already exists */
    BMXAReplace = XATTR_REPLACE, /* set the value, fail if attr does not exist */
};

@interface NSFileManager (BMCommons)

/**
 * Removes all files from the specified directory recursively.
 */
- (BOOL)bmClearContentsOfDirectoryAtPath:(NSString *)path error:(NSError * _Nullable * _Nullable)error;

/**
 Lists the extended attribute names defined for the file at the specified path.
 
 Returns nil if an error occurs.
 
 @param path The file path
 @param follow Whether to follow links or not
 @param error On error filled with error info
 */
- (nullable NSArray*)bmExtendedAttributeNamesAtPath:(NSString *)path traverseLink:(BOOL)follow error:(NSError *_Nullable *_Nullable)error;

/**
 Retrieves the value for the extended attribute with ths specified name as defined for the file at the specified path.
 
 Returns nil if an error occurs or the attribute could not be found.
 
 @param name The name of the attribute
 @param path The file path
 @param follow Whether to follow links or not
 @param error On error filled with error info
 */
- (nullable NSData*)bmExtendedAttribute:(NSString *)name atPath:(NSString *)path traverseLink:(BOOL)follow error:(NSError * _Nullable *_Nullable)error;

/**
 Returns a dictionary with all the extended attributes defined for the file at the specified path.
 
 Returns nil if an error occurs.
 
 @param path The file path
 @param follow Whether to follow links or not
 @param error On error filled with error info
 */
- (nullable NSDictionary*)bmExtendedAttributesAtPath:(NSString *)path traverseLink:(BOOL)follow error:(NSError * _Nullable * _Nullable)error;

/**
 Sets the value for the extended attribute with ths specified name for the file at the specified path.
 
 Returns NO if an error occurs, YES otherwise.
 
 @param name The name of the attribute
 @param value The value for the attribute
 @param path The file path
 @param follow Whether to follow links or not
 @param mode Whether to fail if the attribute already exists, or whether to fail if the attribute does not exist, or to not fail at all in any of these cases.
 @param error On error filled with error info
 @see BMXAMode
 */
- (BOOL)bmSetExtendedAttribute:(NSString *)name value:(NSData *)value atPath:(NSString *)path traverseLink:(BOOL)follow mode:(BMXAMode)mode error:(NSError *_Nullable *_Nullable)error;

/**
 Removes the extended attribute with the specified name as defined for the file at the specified path.
 
 Returns NO if an error occurs, YES otherwise.
 
 @param name The name of the attribute
 @param path The file path
 @param follow Whether to follow links or not
 @param error On error filled with error info
 */
- (BOOL)bmRemoveExtendedAttribute:(NSString *)name atPath:(NSString *)path traverseLink:(BOOL)follow error:(NSError *_Nullable *_Nullable)error;

/**
 Sets the values for all extended attribute with the sepcified dictionary for the file at the specified path.
 
 Returns NO if an error occurs, YES otherwise.
 
 @param attrs Dictionary with the attributes to set
 @param path The file path
 @param follow Whether to follow links or not
 @param overwrite Whether to overwrite existing values or not
 @param error On error filled with error info
 */
- (BOOL)bmSetExtendedAttributes:(NSDictionary *)attrs atPath:(NSString *)path traverseLink:(BOOL)follow overwrite:(BOOL)overwrite error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
