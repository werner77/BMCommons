//
//  BMImmutableProxy.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/15/11.
//  Copyright (c) 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMImmutableProxy.h>
#import <BMCommons/BMPropertyMethod.h>

@implementation BMImmutableProxy

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    BMPropertyMethod *pm = [BMPropertyMethod propertyMethodFromSelector:anInvocation.selector];
    if (pm && pm.isSetter) {
        NSException *ex = [NSException exceptionWithName:@"ImmutableObjectException" reason:@"Trying to modify an immutable object" userInfo:nil];   
        @throw ex;
    } else {
        [super forwardInvocation:anInvocation];
    }
}

@end
