//
//  BMButtonCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 11/06/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMButtonCell.h>
#import <BMCommons/BMUICore.h>

@implementation BMButtonCell

@synthesize button;

- (void)dealloc {
    BM_RELEASE_SAFELY(button);
}

@end
