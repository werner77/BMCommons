//
//  BMImmutableProxy.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/15/11.
//  Copyright (c) 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMProxy.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Proxy that throws an exception when property setters are called, otherwise delegates all messages to the underlying object.
 */
@interface BMImmutableProxy : BMProxy {
}

@end

NS_ASSUME_NONNULL_END
