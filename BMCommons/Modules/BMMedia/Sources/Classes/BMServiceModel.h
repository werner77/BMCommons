//
//  BMServiceModel.h
//  BMCommons
//
//  Created by Werner Altewischer on 24/09/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/Three20Network/BMTTModel.h>
#import <BMCommons/BMService.h>

/**
 BMTTModel implementation with support for loading the model asynchronously using a BMService.

 This instance receives callbacks from the BMService upon return via the BMServiceDelegate protocol.
 
 @see BMService
 @see BMServiceDelegate
 */
@interface BMServiceModel : BMTTModel <BMServiceDelegate>

/**
 The BMService instance to use for loading the data.
 */
@property(nonatomic, strong) id <BMService> service;

/**
 Represents the timestamp of the completed request.
 
 Valid upon completion of the URL request.
*/
@property(nonatomic, strong) NSDate *loadedTime;

/**
 Represents the request's cache key.
 
 Valid upon completion of the URL request.
*/
@property(nonatomic, copy) NSString *cacheKey;

/**
* Resets the model to its original state before any data was loaded.
*/
- (void)reset;

/**
* Returns download progress as between 0 and 1.
 
 Valid while loading.
*/
- (float)downloadProgress;

@end

@interface BMServiceModel(Protected)

/**
 * To be implemented by sub classes
 
 Implement to setup the service before loading.
 */
- (void)prepareService:(id <BMService>)theService forLoadingWithMoreResults:(BOOL)more;

@end
