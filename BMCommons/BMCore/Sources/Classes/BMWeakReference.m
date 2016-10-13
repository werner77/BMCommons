//
//  BMWeakReference.m
//  BMCommons
//
//  Created by Werner Altewischer on 11/28/13.
//  Copyright (c) 2013 BMCommons. All rights reserved.
//

#import <BMCommons/BMWeakReference.h>

@implementation BMWeakReference

+ (BMWeakReference *)weakReferenceWithTarget:(id)target {
    BMWeakReference *ref = [self new];
    ref.target = target;
    return ref;
}

@end
