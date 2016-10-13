//
//  BMDateSelectionViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/25/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#if KAL_ENABLED

#import <Foundation/Foundation.h>
#import <BMCommons/BMEditViewController.h>
#import <BMCommons/BMViewController.h>

@class BMCustomKalViewController;

@interface BMDateSelectionViewController : BMViewController<BMEditViewController> {
	BMPropertyDescriptor *propertyDescriptor;
	__weak id <BMEditViewControllerDelegate> delegate;
	BMCustomKalViewController *kalViewController;
}

@property (nonatomic, strong) BMPropertyDescriptor *propertyDescriptor;

@end

#endif
