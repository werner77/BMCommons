//
// Created by Werner Altewischer on 25/08/2017.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSCharacterSet (BMCommons)

/**
 * Returns a string with all the characters present in the receiver. Every character will be present exactly 1 time.
 *
 * @return String with all the characters in this set.
 */
- (NSString *)bmStringWithCharactersInSet;

/**
 * Returns an array of NSStrings where each string contains one character contained in the receiver. Every character will be present exactly 1 time.
 *
 * @return An array of NSString containing all the characters in this set.
 */
- (NSArray<NSString *> *)bmArrayWithCharactersInSet;

/**
 * Enumerates all the UTF32 characters in this set by calling the specified block for each encountered character.
 * As long as the block returns true the enumeration will continue.
 *
 * @param block The block to perform for each enumerated value
 */
- (void)bmEnumerateCharactersWithBlock:(BOOL (^)(UTF32Char character))block;

@end

NS_ASSUME_NONNULL_END