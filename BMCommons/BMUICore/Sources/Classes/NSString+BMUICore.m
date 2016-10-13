//
// Created by Werner Altewischer on 05/11/15.
// Copyright (c) 2015 BehindMedia. All rights reserved.
//

#import "NSString+BMUICore.h"
#import "NSDictionary+BMCommons.h"
#import <BMCore/BMCore.h>

@implementation NSString (BMUICore)

- (CGSize)bmSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)constraint lineBreakMode:(NSLineBreakMode)lineBreakMode {

    BM_START_IGNORE_TOO_NEW
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {

        NSMutableDictionary *attributes = [NSMutableDictionary new];

        [attributes bmSafeSetObject:font forKey:NSFontAttributeName];

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:lineBreakMode];

        [attributes bmSafeSetObject:paragraphStyle forKey:NSParagraphStyleAttributeName];

        CGRect rect = [self boundingRectWithSize:constraint
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];

        return rect.size;
    } else {
        return [self sizeWithFont:font constrainedToSize:constraint lineBreakMode:lineBreakMode];
    }
    BM_END_IGNORE_TOO_NEW
}

@end