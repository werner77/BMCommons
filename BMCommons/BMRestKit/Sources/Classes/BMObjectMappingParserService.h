//
//  BMObjectMappingParserService.h
//  BMCommons
//
//  Created by Werner Altewischer on 3/8/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMRestKit/BMParserService.h>
#import <BMRestKit/BMMappableObject.h>

/**
 Implementation of parser service that uses BMObjectMappingParserHandler to automatically map XML/JSON responses to objects.
 */
@interface BMObjectMappingParserService : BMParserService {
    @private
	NSString *rootXPath;
	NSString *errorXPath;
	Class<BMMappableObject> rootElementClass;
	Class<BMMappableObject> errorElementClass;
}

/**
 XPath to the root element which acts as the starting point for the mapping.
 */
@property (nonatomic, strong) NSString *rootXPath;

/**
 XPath that is the root element of an error response (in case the error response is different from the normal response)
 */
@property (nonatomic, strong) NSString *errorXPath;

/**
 The class of the mappable object (implementation of BMMappableObject) that maps to the xml under rootXPath.
 */
@property (nonatomic, strong) Class<BMMappableObject> rootElementClass;

/**
 The class of the mappable object (implementation of BMMappableObject) that maps to the xml under errorXPath.
 */
@property (nonatomic, strong) Class<BMMappableObject> errorElementClass;

@end
