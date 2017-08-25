//
//  BMMIMEType.h
//  BMCommons
//
//  Created by Werner Altewischer on 01/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Registry of MIME types.
 
 A MIME type contains a contentType string such as "image/jpeg" and a list of extensions such as ["jpe", "jpg", jpeg"]
 */
@interface BMMIMEType : BMCoreObject

/**
 The content type for this MIME type, such as "image/jpeg" or "text/plain".
 */
@property (nonatomic, strong) NSString *contentType;

/**
 The possible file extensions for this MIME type.
 
 For example "jpe", "jpg", "jpeg" for content type "image/jpeg".
 */
@property (nonatomic, strong) NSArray *fileExtensions;

/**
 Returns the known MIME type for the specified fileExtension or nil if not recognized.
 */
+ (nullable BMMIMEType *)mimeTypeForFileExtension:(NSString *)fileExtension;

/**
 Returns the known MIME type for the specified contentType or nil if not recognized.
 */
+ (nullable BMMIMEType *)mimeTypeForContentType:(NSString *)contentType;

@end

NS_ASSUME_NONNULL_END
