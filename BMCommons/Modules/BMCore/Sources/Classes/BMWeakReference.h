//
//  BMWeakReference.h
//  BMCommons
//
//  Created by Werner Altewischer on 11/28/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMWeakReference : NSObject

@property (weak) id target;

+ (BMWeakReference *)weakReferenceWithTarget:(id)target;

@end
