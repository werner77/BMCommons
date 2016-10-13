//
//  BMKeyValuePair.h
//  BMCommons
//
//  Created by Werner Altewischer on 1/13/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMKeyValuePair : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) id value;

@end
