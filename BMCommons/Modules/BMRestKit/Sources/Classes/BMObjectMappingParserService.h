//
//  BMObjectMappingParserService.h
//  BMCommons
//
//  Created by Werner Altewischer on 3/8/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMParserService.h>
#import <BMCommons/BMMappableObject.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Implementation of parser service that uses BMObjectMappingParserHandler to automatically map XML/JSON responses to objects.
 */
@interface BMObjectMappingParserService : BMParserService {
}

/**
 XPath to the root element which acts as the starting point for the mapping.
 */
@property (nullable, strong) NSString *rootXPath;

/**
 XPath that is the root element of an error response (in case the error response is different from the normal response)
 */
@property (nullable, strong) NSString *errorXPath;

/**
 The class of the mappable object (implementation of BMMappableObject) that maps to the xml under rootXPath.
 */
@property (strong) Class<BMMappableObject> rootElementClass;

/**
 The class of the mappable object (implementation of BMMappableObject) that maps to the xml under errorXPath.
 */
@property (strong, nullable) Class<BMMappableObject> errorElementClass;

- (instancetype)initWithRootXPath:(nullable NSString *)rootXPath rootElementClass:(Class<BMMappableObject>)rootElementClass
                       errorXPath:(nullable NSString *)errorXPath errorElementClass:(nullable Class<BMMappableObject>)errorElementClass NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
