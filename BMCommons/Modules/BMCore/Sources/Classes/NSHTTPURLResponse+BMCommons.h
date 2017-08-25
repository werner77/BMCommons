//
// Created by Werner Altewischer on 13/01/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSHTTPURLResponse (BMCommons)

/**
 * Returns the value for the specified header key.
 *
 * Works case-insensitive.
 */
- (nullable NSString *)bmValueForHeader:(NSString *)header;

/**
 * Returns the content character encoding if sent as a response header or 0 otherwise.
 */
- (NSStringEncoding)bmContentCharacterEncoding;

@end

NS_ASSUME_NONNULL_END