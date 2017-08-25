//
// Created by Werner Altewischer on 25/08/2017.
//

#import "NSCharacterSet+BMCommons.h"
#import "NSString+BMCommons.h"

@implementation NSCharacterSet (BMCommons)

- (NSString *)bmStringWithCharactersInSet {
    NSMutableString *ret = [NSMutableString new];
    [self bmEnumerateCharactersWithBlock:^BOOL(UTF32Char character) {
        [ret appendString:[NSString bmStringWithUTF32Char:character]];
        return YES;
    }];
    return ret;
}

- (NSArray<NSString *> *)bmArrayWithCharactersInSet {
    NSMutableArray *ret = [NSMutableArray new];
    [self bmEnumerateCharactersWithBlock:^BOOL(UTF32Char character) {
        [ret addObject:[NSString bmStringWithUTF32Char:character]];
        return YES;
    }];
    return ret;
}

- (void)bmEnumerateCharactersWithBlock:(BOOL (^)(UTF32Char character))block {
    for (UInt32 plane = 0; plane <= 16; plane++) {
        if ([self hasMemberInPlane:(UInt8)plane]) {
            UTF32Char c;
            for (c = plane << 16; c < (plane+1) << 16; c++) {
                if ([self longCharacterIsMember:c]) {
                    if (block == nil || !block(c)) {
                        return;
                    }
                }
            }
        }
    }
}

@end