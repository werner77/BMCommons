//
//  BMMediaItemWithDuration.m
//  BMCommons
//
//  Created by Werner Altewischer on 24/09/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMMediaItemWithDuration.h>

@implementation BMMediaItemWithDuration {
    NSNumber *duration;
}

@synthesize duration;

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.duration forKey:@"duration"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        self.duration = [coder decodeObjectForKey:@"duration"];
    }
    return self;
}


@end