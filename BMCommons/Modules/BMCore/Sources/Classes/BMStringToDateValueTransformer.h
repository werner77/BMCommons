//
//  BMStringToDateValueTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/18/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Transforms a date to a string and vice versa. 
 
 The date formatter to use is configurable. The method [NSDateFormatter bmDateByParsingFromString:] (declared in the BMCommons category of NSDateFormatter) is used to convert in the forward direction.
 */
@interface BMStringToDateValueTransformer : NSValueTransformer

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

/** 
 Converts NSString in ISO Date format (yyyy-MM-dd) to NSDate, using the timezone from the current locale.
 */
+ (BMStringToDateValueTransformer *)isoStringToDateValueTransformer;

- (id)initWithDateFormatter:(NSDateFormatter *)theDateFormatter;

@end

NS_ASSUME_NONNULL_END
