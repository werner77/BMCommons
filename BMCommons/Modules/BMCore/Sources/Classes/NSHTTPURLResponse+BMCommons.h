//
// Created by Werner Altewischer on 13/01/17.
//

#import <Foundation/Foundation.h>

@interface NSHTTPURLResponse (BMCommons)

/**
 * Returns the value for the specified header key.
 *
 * Works case-insensitive.
 *
 * @param header
 * @return
 */
- (NSString *)bmValueForHeader:(NSString *)header;

/**
 * Returns the content character encoding if sent as a response header or 0 otherwise.
 *
 * @return
 */
- (NSStringEncoding)bmContentCharacterEncoding;

@end