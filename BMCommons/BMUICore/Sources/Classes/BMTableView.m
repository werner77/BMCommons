//
//  BMTableView.m
//  BMCommons
//
//  Created by Werner Altewischer on 5/12/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMTableView.h"

@implementation BMTableView

- (id <BMReusableObject>)dequeueReusableObjectWithIdentifier:(NSString *)identifier {
    return [self dequeueReusableCellWithIdentifier:identifier];
}

@end
