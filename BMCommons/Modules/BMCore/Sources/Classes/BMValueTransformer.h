//
//  BMValueTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/7/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 NSValueTransformer implementation that takes targets/selectors as converter methods for both forward and inverse tranformation.
 
 If target is nil the specified selector is called on the value itself upon conversion.
 
 *Example*
 
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"dd-MM-yyyy"];
    NSValueTranformer *vt = [[BMValueTransformer alloc] initWithConverterTarget:df converterSelector:@selector(dateFromString:) inverseTarget:df inverseSelector:@selector(stringFromDate:)];
    NSDate *date = [vt transformedValue:@"01-01-2013"];
    NSString *dateString = [vt reverseTransformedValue:date];
 
 */
@interface BMValueTransformer : NSValueTransformer

@property (nullable, nonatomic, strong) id converterTarget;
@property (nullable, nonatomic, strong) id inverseConverterTarget;
@property (nullable, nonatomic, assign) SEL converterSelector;
@property (nullable, nonatomic, assign) SEL inverseConverterSelector;

- (id)initWithConverterTarget:(id)target converterSelector:(SEL)converterSelector 
				inverseTarget:(id)inverseTarget inverseSelector:(SEL)inverseSelector;

@end

NS_ASSUME_NONNULL_END