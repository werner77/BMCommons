//
//  BMLogging.c
//  BMCommons
//
//  Created by Werner Altewischer on 18/03/15.
//  Copyright (c) 2015 BehindMedia. All rights reserved.
//
#import <Foundation/Foundation.h>

static volatile BOOL bmLoggingEnabled = YES;

void BMLog(BOOL threadSafe, NSString *format, ...) {
    if (bmLoggingEnabled) {        
        if (threadSafe) {
            static dispatch_once_t onceToken = 0;
            static NSObject *lock = nil;
            
            dispatch_once(&onceToken, ^{
                lock = [NSObject new];
            });
            
            @synchronized(lock) {
                
                va_list args;
                
                va_start(args, format);
                
                NSLogv(format, args);
                
                va_end(args);
            }
        } else {
            
            va_list args;
            
            va_start(args, format);
            
            NSLogv(format, args);
            
            /* Clean up the va_list */
            va_end(args);
        }
    }
}

void BMLogSetEnabled(BOOL enabled) {
    bmLoggingEnabled = enabled;
}

BOOL BMLogIsEnabled(void) {
    return bmLoggingEnabled;
}