//
//  BMCustomKalViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/25/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#if KAL_ENABLED

#import <Foundation/Foundation.h>
#import "KalViewController.h"

@interface BMCustomKalViewController : KalViewController {
	__weak id target;
	SEL selector;
	BOOL ignore;
}

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

@end

#endif

