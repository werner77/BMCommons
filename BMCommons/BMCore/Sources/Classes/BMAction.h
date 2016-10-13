//
//  BMAction.h
//  BMCommons
//
//  Created by Werner Altewischer on 1/4/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCore/BMCoreObject.h>

/**
 Class that encapsulates a target/selector combination.
 */
@interface BMAction : BMCoreObject {
    @private
	id __weak _target;
	SEL _selector;
}

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

@end
