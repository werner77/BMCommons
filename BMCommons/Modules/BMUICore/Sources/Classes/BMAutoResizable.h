/*
 *  BMAutoResizable.h
 *  BMCommons
 *
 *  Created by Werner Altewischer on 12/20/10.
 *  Copyright 2010 BehindMedia. All rights reserved.
 *
 */

/**
 Protocol defining a property for the capability to size to fit the contents.
 */
@protocol BMAutoResizable<NSObject>

@property (nonatomic, assign) BOOL sizeToFit;

@end