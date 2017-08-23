//
//  BMDigest.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/06/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BMDigestType) {
    BMDigestTypeMD5,
    BMDigestTypeSHA1,
    BMDigestTypeSHA256,
};

NS_ASSUME_NONNULL_BEGIN

/**
 Utility class for calculating digests.
 */
@interface BMDigest : NSObject

+ (instancetype)digestOfType:(BMDigestType)type;

/**
 Updates the digest with the specified data. 
 
 If last is set the digest is finalized and no further data can be appended.
 */
- (void)updateWithData:(nullable NSData *)data last:(BOOL)last;

/**
 Updates the digest with the specified bytes and length.
 
 If last is set the digest is finalized and no further data can be appended.
 */
- (void)updateWithBytes:(const void * _Nullable)bytes length:(NSUInteger)length last:(BOOL)last;

/**
 Updates the digest with the values as returned from the properties of the specified object.
 
 propertyDescriptors should be an array of BMPropertyDescriptor objects.
 */
- (void)updateWithProperties:(NSArray *)propertyDescriptors fromObject:(id)object;

/**
 Updates the digest with the values as returned from the properties for the specified keypaths of the specified object.
 
 propertyDescriptors should be an array of BMPropertyDescriptor objects.
 */
- (void)updateWithValueForKeyPaths:(NSArray *)keyPaths fromObject:(id)object;

/**
 The resulting digest as NSData.
 
 Returns nil if not yet finalized.
 */
- (nullable NSData *)dataRepresentation;

/**
 The resulting digest as Hex encoded string.
 
 Returns nil if not yet finalized.
 */
- (nullable NSString *)stringRepresentation;

/**
 Finalizes the digest.
 
 Before this method is called the digest will return nil for both dataRepresentation and stringRepresentation.
 */
- (void)finalizeDigest;

@end

//To be implemented by sub classes
@interface BMDigest(Protected)

- (NSUInteger)lengthForDigest;

- (void)initDigest;
- (void)updateDigestWithBytes:(const void *)bytes length:(NSUInteger)length;
- (void)finalizeDigestWithResult:(unsigned char *)result;

@end

NS_ASSUME_NONNULL_END
