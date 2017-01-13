//
//  BMTestCodeableObject.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/10/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMTestCodeableObject : NSObject<NSCoding>

@property (nonatomic, strong) NSDate *dateProperty;
@property (nonatomic, strong) NSNumber *numberProperty;
@property (nonatomic, strong) NSString *stringProperty;
@property (nonatomic, assign) NSInteger intProperty;
@property (nonatomic, assign) BOOL boolProperty;
@property (nonatomic, assign) double doubleProperty;
@property (nonatomic, assign) float floatProperty;

@end
