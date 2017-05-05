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

/**
 Implementation of parser service that uses BMObjectMappingParserHandler to automatically map XML/JSON responses to objects.
 */
@interface BMObjectMappingParserService : BMParserService {
}

/**
 XPath to the root element which acts as the starting point for the mapping.
 */
@property (strong) NSString *rootXPath;

/**
 XPath that is the root element of an error response (in case the error response is different from the normal response)
 */
@property (strong) NSString *errorXPath;

/**
 The class of the mappable object (implementation of BMMappableObject) that maps to the xml under rootXPath.
 */
@property (strong) Class<BMMappableObject> rootElementClass;

/**
 The class of the mappable object (implementation of BMMappableObject) that maps to the xml under errorXPath.
 */
@property (strong) Class<BMMappableObject> errorElementClass;

@end
