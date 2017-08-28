//
//  BMServiceModelTableViewController.h
//  BMCommons
//
//  Created by Werner Altewischer on 02/05/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMTableViewController.h>
#import <BMCommons/BMService.h>

NS_ASSUME_NONNULL_BEGIN

/**
 BMTableViewController sub-class which implements loading using the BMService framework.
 
 Call the performService: method with a concrete BMService implementation to initiate the loading process.
 The [BMTableViewController startedLoading] and [BMTableViewController finishedLoadingWithSuccess:] methods are called when the BMService starts loading and finishes loading respectively.
 
 Upon succesful completion the handleServiceResult: method is called which should be overridden by sub-classes.
 */
@interface BMServiceModelTableViewController : BMTableViewController<BMServiceDelegate>

- (void)performService:(id <BMService>)service;

@end

@interface BMServiceModelTableViewController(Protected)

/**
 Sub-classes should override this method with a meaningful implementation to handle the service result.
 
 Default implementation is empty. Sub-classes are responsible for converting/storing the result and calling reloadData if necessary.
 */
- (void)handleResult:(id)result forService:(id<BMService>)service;

@end

NS_ASSUME_NONNULL_END
