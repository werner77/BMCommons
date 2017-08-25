//
//  NSData+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 13/11/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (BMCommons)

- (nullable NSString *)bmStringUsingEncoding:(NSStringEncoding)encoding;
- (NSString *)bmHexEncodedString;
- (NSString *)bmBase64EncodedString;

- (BOOL)bmIsJPGData;
- (BOOL)bmIsPNGData;

@end

NS_ASSUME_NONNULL_END
