//
//  BMPropertyMethod.m
//  BM
//
//  Created by Werner Altewischer on 12/15/11.
//  Copyright (c) 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMPropertyMethod.h>
#import <BMCommons/BMStringHelper.h>

@implementation BMPropertyMethod

@synthesize setter = _setter, propertyName = _propertyName;

+ (BMPropertyMethod *)propertyMethodFromSelector:(SEL)selector {
	return [[self alloc] initWithSelector:selector];
}

- (id)initWithPropertyName:(NSString *)thePropertyName setter:(BOOL)isSetter {
    if ((self = [super init])) {
        _propertyName = thePropertyName;
        _setter = isSetter;
    }
    return self;
}

- (id)initWithSelector:(SEL)selector {
    NSString *selectorName = NSStringFromSelector(selector);
	NSInteger numberOfArguments = [selectorName componentsSeparatedByString:@":"].count - 1;
	
	//Extract the property name and determine if it's a getter or setter
	NSString *thePropertyName = nil;
	BOOL isSetter = NO;
	if ([selectorName hasPrefix:@"set"] && selectorName.length > 3 && numberOfArguments == 1) {
		isSetter = YES;
		thePropertyName = [BMStringHelper stringByConvertingFirstCharToLowercase:[[selectorName substringToIndex:selectorName.length - 1] substringFromIndex:3]];
	} else if (numberOfArguments == 0) {
		if ([selectorName hasPrefix:@"is"] && selectorName.length > 2) {
			thePropertyName = [BMStringHelper stringByConvertingFirstCharToLowercase:[selectorName substringFromIndex:2]];
		} else {
			thePropertyName = selectorName;
		}
	} 
    
    if (thePropertyName) {
        return [self initWithPropertyName:thePropertyName setter:isSetter];
    } else {
        return nil;
    }
}



@end

