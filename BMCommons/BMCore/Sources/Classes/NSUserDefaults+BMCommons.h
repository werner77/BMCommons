//
//  NSUserDefaults+BMCommons.h
//  BMCommons
//
//  Created by Werner Altewischer on 4/7/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (BMCommons)

- (void)bmSafeSetObject:(id)object forKey:(NSString *)key;

@end
