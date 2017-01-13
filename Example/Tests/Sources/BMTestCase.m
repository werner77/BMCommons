//
//  BMTestCase.m
//  BMCommons
//
//  Created by Werner Altewischer on 13/01/17.
//  Copyright © 2017 Werner Altewischer. All rights reserved.
//

#import "BMTestCase.h"
#import <BMCommons/BMSingleton.h>

@implementation BMTestCase

+ (NSBundle *)testBundle {
    return [NSBundle bundleForClass:self];
}

- (void) setUp {
    [super setUp];
    
    //Releases all shared instances
    [BMSingleton releaseAllSharedInstances];
}

- (NSData *)dataForResource:(NSString *)resourceName ofType:(NSString *)resourceType {
    NSString *resourcePath = [[self.class testBundle] pathForResource:resourceName ofType:resourceType];
    return [NSData dataWithContentsOfFile:resourcePath];
}

@end
