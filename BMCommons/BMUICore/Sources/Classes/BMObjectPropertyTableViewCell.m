//
//  BMObjectPropertyTableViewCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 10/7/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import "BMObjectPropertyTableViewCell.h"
#import "BMStringHelper.h"
#import <BMCommons/BMUICore.h>

@interface BMObjectPropertyTableViewCell (Private)

- (void)checkSupportedValue:(id)value;

@end


@implementation BMObjectPropertyTableViewCell {
	BMPropertyDescriptor *propertyDescriptor;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *commentLabel;
	BOOL initialized;
	id<BMObjectPropertyTableViewCellDelegate> __weak delegate;
	NSValueTransformer *valueTransformer;
	BOOL valueRequired;
    CGFloat rowHeight;
    BOOL valid;
}

@synthesize titleLabel, commentLabel, delegate, valueTransformer, valid, valueRequired, rowHeight;

+ (Class)supportedValueClass {
	return nil;
}

+ (BOOL)isSupportedValue:(id)value {
    Class supportedClass = [self supportedValueClass];
	return !value || !supportedClass || [value isKindOfClass:supportedClass];
}

+ (CGFloat)heightForValue:(id)value {
    return BM_ROW_HEIGHT;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	if (!initialized) {
		[self initialize];
		initialized = YES;
	}
}

- (void)constructCellWithObject:(NSObject *)theObject propertyName:(NSString *)thePropertyName {
	if (!initialized) {
		[self initialize];
		initialized = YES;
	}
	
	BM_RELEASE_SAFELY(propertyDescriptor);
	propertyDescriptor = [BMPropertyDescriptor propertyDescriptorFromKeyPath:thePropertyName withTarget:theObject];
	
	[self updateCellValueFromObject];
}

- (void)constructCellWithObject:(NSObject *)theObject 
				   propertyName:(NSString *)thePropertyName
					  titleText:(NSString *)titleText {
	self.titleLabel.text = titleText;
	[self constructCellWithObject:theObject propertyName:thePropertyName];
}

- (void)dealloc {
	BM_RELEASE_SAFELY(propertyDescriptor);
}

- (BMPropertyDescriptor *)propertyDescriptor {
	return propertyDescriptor;
}

- (void)prepareForReuse {
	[super prepareForReuse];
	BM_RELEASE_SAFELY(propertyDescriptor);
	self.valueTransformer = nil;
	delegate = nil;
}

- (void)setValid:(BOOL)v {
    valid = v;
    [self updateViewForValidityStatus:valid];
}

@end

@implementation BMObjectPropertyTableViewCell(Protected)

- (void)updateViewForValidityStatus:(BOOL)valid {
	
}

- (BOOL)validateValue:(id *)value transformedValue:(id *)transformedValue {
	NSError *error = nil;
	
	if (*value == nil && *transformedValue != nil && ![*transformedValue isEqual:@""]) {
		//No convertible value: fail validation
		return NO;
	} else if (self.valueRequired && *value == nil) {
		return NO;
	} else {
		return [propertyDescriptor validateValue:value withError:&error];
	}
}


- (void)updateCellValueFromObject {
	id currValue;
	if (![BMStringHelper isEmpty:propertyDescriptor.keyPath]) {
		currValue = [propertyDescriptor callGetter];
	} else {
		currValue = propertyDescriptor.target;
	}
	
	id transformedValue = currValue;
	if (self.valueTransformer) {
		transformedValue = [self.valueTransformer transformedValue:currValue];
	}
	
	[self checkSupportedValue:transformedValue];
	
    [self setValid:[self validateValue:&currValue transformedValue:&transformedValue]];	
	[self setViewWithData:transformedValue];
}

- (void)updateObjectWithCellValue {
	id transformedValue = [self dataFromView];
	id newValue = transformedValue;
	
	if (self.valueTransformer) {
		newValue = [self.valueTransformer reverseTransformedValue:transformedValue];
	}
	
	valid = [self validateValue:&newValue transformedValue:&transformedValue];
	[self updateViewForValidityStatus:valid];
	
	if (![BMStringHelper isEmpty:propertyDescriptor.keyPath]) {
		[propertyDescriptor callSetter:newValue];
	} else {
		propertyDescriptor.target = newValue;
	}
	
	if ([self.delegate respondsToSelector:@selector(objectPropertyTableViewCell:didUpdateObjectWithValue:)]) {
		[self.delegate objectPropertyTableViewCell:self didUpdateObjectWithValue:newValue];
	}
}

- (id)dataFromView {
	return nil;
}

- (void)setViewWithData:(id)value {
}

- (void)initialize {
    rowHeight = [[self class] heightForValue:nil];
}

- (id)data {
    return [self.propertyDescriptor callGetter];
}

@end

@implementation BMObjectPropertyTableViewCell(Private)

- (void)checkSupportedValue:(id)value {
	if (![[self class] isSupportedValue:value]) {
		NSException *exception = [NSException exceptionWithName:@"IllegalArgumentException" 
														 reason:[NSString stringWithFormat:@"Illegal value supplied: %@ (%@). Failed property: %@ of object: %@", 
																 value, 
																 NSStringFromClass([value class]),
																 self.propertyDescriptor.keyPath, 
																 self.propertyDescriptor.target] 
													   userInfo:nil];
		@throw exception;
	}
}

@end
