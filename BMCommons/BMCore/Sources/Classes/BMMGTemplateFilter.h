/*
 *  MGTemplateFilter.h
 *
 *  Created by Matt Gemmell on 12/05/2008.
 *  Copyright 2008 Instinctive Code. All rights reserved.
 *
 */
#import <Foundation/Foundation.h>

/**
 Filter for BMMGTemplateEngine.
 */
@protocol BMMGTemplateFilter

- (NSArray *)filters;
- (NSObject *)filterInvoked:(NSString *)filter withArguments:(NSArray *)args onValue:(NSObject *)value;

@end
