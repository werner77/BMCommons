//
//  BMKeyboardListener.m
//  BMCommons
//
//  Created by Werner Altewischer on 8/12/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMKeyboardListener.h"
#import <BMCommons/BMUICore.h>

@implementation BMKeyboardListener {
    BOOL _visible;
}

@synthesize visible = _visible;

+ (void)initialize {
    [self sharedInstance];
}

+ (BMKeyboardListener *) sharedInstance {
    static BMKeyboardListener *sListener = nil;    
    if ( nil == sListener ) {
        sListener = [[BMKeyboardListener alloc] init];
    }
    return sListener;
}

-(id) init {
    self = [super init];
    if ( self ) {
        BMUICoreCheckLicense();
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(noticeShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(noticeHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void) noticeShowKeyboard:(NSNotification *)inNotification {
    _visible = true;
}

-(void) noticeHideKeyboard:(NSNotification *)inNotification {
    _visible = false;
}

@end
